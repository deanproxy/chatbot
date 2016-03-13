require_relative 'command'

class Default < Command
    def respond
        quotes = []
        @client.db.execute('select text from quotes') do |row|
            quotes << row[0]
        end

        if quotes.length == 0
            send("I am not sure what you're asking...", @is_pm)
        else
            case text.downcase
            when /hansel(.*)/
                send("I hate Hansel! Everywhere I look, Hansel, Hansel, Hansel!", @is_pm)
            when /^can you(.*)/
                send("I can do a lot of things. Try asking for help.", @is_pm)
            when /^quote$/
                send(quotes[Random.rand(quotes.length-1)])
            end
        end
    end
end

