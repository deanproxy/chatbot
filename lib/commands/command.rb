class Command
    attr_reader :params
    attr_accessor :room
    attr_accessor :nick
    attr_accessor :text
    attr_accessor :client
    attr_accessor :is_pm
    attr_accessor :time

    def send(message, force_pm=false)
        if force_pm || !@room
            @client.send_message(@nick, message)
        else
            @client.send(@room, message)
        end
    end

    def initialize(params)
        @params = params
    end

    def set_attributes(client, time, nick, room, text=nil, is_pm=false)
        @nick = nick
        @client = client
        @time = time
        @text = text || @text
        @room = room
        @is_pm = is_pm
    end

    def respond
        # Do stuff
    end
end
