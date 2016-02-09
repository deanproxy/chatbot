require 'command'

class Salute < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        if @params[0].downcase =~ /i love you/
            client.send(room, 'Aww... shucks...')
        elsif @params[0].downcase =~ /welcome back/
            client.send(room, "Hey, thanks! Great to be back.")
        else
            responses = [
                "What's up",
                "Howdy",
                "Yo",
                "What it is, my main human?"
            ]
            client.send(room, responses[Random.rand(responses.length-1)])
        end
    end
end

