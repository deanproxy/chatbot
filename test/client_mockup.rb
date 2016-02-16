require 'sqlite3'
require 'logger'

class ClientMockup
    def db
        return @db
    end

    def log
        return @log
    end

    def config
        return @config
    end

    def initialize(options={})
        @config = options
        @log = Logger.new($stdout)
        @db = SQLite3::Database.new('test.db')
        @last_send_msg = []

        File.open("./schema/schema.sql") do |f|
            @db.execute(f.read())
        end
    end

    def finalize
        @db.close
        File.unlink('test.db')
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
