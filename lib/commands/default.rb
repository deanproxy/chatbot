require "./lib/commands/command"

class Default < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        quotes = []
        client.db.execute('select text from quotes') do |row|
            quotes << row[0]
        end

        if quotes.length == 0
            client.send(room, "I am not sure what you're asking...")
        else
            case text.downcase
            when /hansel(.*)/
                client.send(room, "I hate Hansel! Everywhere I look, Hansel, Hansel, Hansel!")
            when /^can you(.*)/
                client.send(room, "I can do a lot of things. Try asking for help.")
            else
                client.send(room, quotes[Random.rand(quotes.length-1)])
            end
        end
    end
end

