require 'command'

class Die < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.send(room, "Okay. I'll kill myself now... :(")
        raise "Die"
    end
end

