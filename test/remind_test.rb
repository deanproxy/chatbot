require 'test/unit'

require_relative 'client_mockup'
require_relative "../lib/commands/remind.rb"

class RemindTest < Test::Unit::TestCase
    def setup
        @client = ClientMockup.new
    end

    def teardown
        @client.finalize
    end

    def test_create_reminder
        params = ['the room', 'you are testing', 'in', '1 minute']
        r = Remind.new(params)
        r.respond(@client, 'bob')
        t = Time.new
        t = t + 60
        rtime = DateTime.parse(t.to_s)
        english = rtime.strftime("%m/%d/%Y %l:%M%p")

        assert_equal(@client.last_send_msg[0], "Okay. I've set a reminder `#{params[1]}` at #{english}")
        @client.db.execute("select id,jid,time,text,room from reminders") do |row|
            assert_equal(row[0], 1)
            assert_equal(row[1], '@all')
            t = DateTime.parse(row[2])
            assert_equal(t.strftime("%m/%d/%Y %l:%M%p"), english)
            assert_equal(row[3], 'you are testing')
            assert_equal(row[4], 'bob')
        end
    end
end
