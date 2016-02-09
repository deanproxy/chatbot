require 'command'

class Die < Command
    def respond(client, time=nil, nick=nil, text=nil)
        client.send("Okay. I'll kill myself now... :(")
        raise "Die"
    end
end

