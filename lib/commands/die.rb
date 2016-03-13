require_relative 'command'

class Die < Command
    def respond
        if text.downcase != "please die"
            send("You didn't say the magic word.", @is_pm)
            return
        end
        send("Okay. I'll kill myself now... :(", @is_pm)
        raise "Die"
    end
end

