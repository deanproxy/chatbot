require 'minitest/autorun'

require_relative 'client_mockup'
require_relative "../lib/commands/remind"
require_relative '../lib/commands/command_parser'
require_relative '../lib/commands/default'

class RemindTest < MiniTest::Test
    def setup
        @client = ClientMockup.new({
            'hipchat' => {
                'botname' => 'test'
            },
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
    end

    def test_create_reminder
        # Test a failure. If the person is not saying "remind me" or "remind @someuser" 
        # it should go to the default parser.
        a = CommandParser::parse('remind some guy to say hi in 1 minute')
        assert_equal(a.class, Default)

        a = CommandParser::parse('remind me to pee in 3 minutes')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], 'pee')
        assert_equal(a.params[1], 'in')
        assert_equal(a.params[2], '3 minutes')
        t = Time.new
        t = t + 180 
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")
        a.respond(@client, 'bobroom', nil, 'bob')
        assert_equal(@client.last_send_msg[0], "Okay. I've set a reminder for you to `pee` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], @client.users['bob']['jid'])
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'pee')
            assert_equal(row[4], nil)
        end
        @client.db.execute('delete from reminders')

        a = CommandParser::parse('remind @all to pee at 12/10/2020 1:15pm')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], '@all')
        assert_equal(a.params[1], nil)
        assert_equal(a.params[2], 'pee')
        assert_equal(a.params[3], 'at')
        assert_equal(a.params[4], '12/10/2020 1:15pm')
        a.respond(@client, 'bobroom')
        t = Time.new(2020, 10, 12, 13, 15)
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], "Okay. I've set a reminder `pee` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], '@all')
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'pee')
            assert_equal(row[4], 'bobroom')
        end
        @client.db.execute('delete from reminders')

        a = CommandParser::parse('remind @bob he needs to pee on 12/10/2020 2:00pm')
        assert_equal(a.class, Remind)
        assert_equal(a.params[0], '@bob')
        assert_equal(a.params[1], 'he')
        assert_equal(a.params[2], 'needs to pee')
        assert_equal(a.params[3], 'on')
        assert_equal(a.params[4], '12/10/2020 2:00pm')
        a.respond(@client, 'bobroom')
        t = Time.new(2020, 10, 12, 14, 0)
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], 
                     "Okay. I've set a reminder `you needs to pee` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[1], '@bob')
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'you needs to pee')
            assert_equal(row[4], 'bobroom')
        end
        @client.db.execute('delete from reminders')
    end
end
