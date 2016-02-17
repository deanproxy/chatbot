require_relative 'command'

class Die < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        if text.downcase != "please die"
            client.send(room, "You didn't say the magic word.")
            return
        end
        client.send(room, "Okay. I'll kill myself now... :(")
        raise "Die"
    end
end

