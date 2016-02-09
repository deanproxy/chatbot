require 'command'

class Default < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.send(room, "I am not sure what you're asking...")
    end
end

