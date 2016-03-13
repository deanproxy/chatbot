require 'sqlite3'
require 'logger'

class ClientMockup
    attr_reader :db, :log, :config, :users

    def initialize(options={})
        @config = options
        @log = Logger.new($stdout)
        @db = SQLite3::Database.new('test.db')
        @last_send_msg = []
        @users = options[:users] || {}

        File.open("./schema/schema.sql") do |f|
            @db.execute(f.read())
        end
    end

    def finalize
        @db.close
        File.unlink('test.db')
    end

    def send_message(nick, text)
        @last_send_msg << text
    end

    def send(room, msg, to=nil)
        @last_send_msg << msg
    end

    def last_send_msg
        msgs = @last_send_msg.clone
        @last_send_msg.clear
        return msgs
    end
end
