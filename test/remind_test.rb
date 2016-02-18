require 'test/unit'

require_relative 'client_mockup'
require_relative "../lib/commands/remind"
require_relative '../lib/commands/command_parser'
require_relative '../lib/commands/default'

class RemindTest < Test::Unit::TestCase
    def setup
        @client = ClientMockup.new({
            :users => {
                'bob' => {
                    'jid' => '123@chat.hipchat.com',
                    'mention' => '@bob',
                    'email' => 'bob@bob.com'
                }
            }
        })
    end

    def teardown
        @client.finalize
    end

    def test_regex_parsing
        a = CommandParser::parse('remind me to pee in 3 minutes')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], 'pee')
        assert_equal(a.params[1], 'in')
        assert_equal(a.params[2], '3 minutes')

        a = CommandParser::parse('remind @all to pee at 12/10/2020 1:15pm')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], '@all')
        assert_equal(a.params[1], 'pee')
        assert_equal(a.params[2], 'at')
        assert_equal(a.params[3], '12/10/2020 1:15pm')

        a = CommandParser::parse('remind @bob to pee on 12/10/2020 2:00pm')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], '@bob')
        assert_equal(a.params[1], 'pee')
        assert_equal(a.params[2], 'on')
        assert_equal(a.params[3], '12/10/2020 2:00pm')

        # Test a failure. If the person is not saying "remind me" or "remind @someuser" 
        # it should go to the default parser.
        a = CommandParser::parse('remind some guy to say hi in 1 minute')
        assert_equal(a.class, Default)
    end

    def test_create_reminder
        params = ['@all', 'you are testing', 'in', '1 minute']
        r = Remind.new(params)
        r.respond(@client, 'bob')
        t = Time.new
        t = t + 60
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], "Okay. I've set a reminder `#{params[1]}` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], params[0])
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'you are testing')
            assert_equal(row[4], 'bob')
        end
        @client.db.execute('delete from reminders')

        params[0] = '@bob'
        r = Remind.new(params)
        r.respond(@client, 'bobroom')
        t = Time.new
        t = t+60
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], "Okay. I've set a reminder `#{params[1]}` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], params[0])
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'you are testing')
            assert_equal(row[4], 'bobroom')
        end
        @client.db.execute('delete from reminders')

        params = ['wear a shirt', 'in', '1 minute']
        r = Remind.new(params)
        r.respond(@client, 'bobroom', nil, 'bob')
        t = Time.new
        t = t+60
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], 
                     "Okay. I've set a reminder for you to `#{params[0]}` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], @client.users['bob']['jid'])
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], params[0])
            assert_equal(row[4], nil)
        end
        @client.db.execute('delete from reminders')
    end
end
