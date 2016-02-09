require 'command'

class Default < Command
    def respond(client, time=nil, nick=nil, text=nil)
        client.send("I am not sure what you're asking...")
    end
end

