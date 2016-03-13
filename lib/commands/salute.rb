require_relative 'command'

class Salute < Command
    def respond
        if @params[1].downcase =~ /i love you/
            send(room, 'Aww... shucks...', @is_pm)
        elsif @params[1].downcase =~ /welcome back/
            send(room, "Hey, thanks! Great to be back.", @is_pm)
        else
            responses = [
                "What's up",
                "Howdy",
                "Yo",
                "What it is, my main human?"
            ]
            send(responses[Random.rand(responses.length-1)], @is_pm)
        end
    end
end

