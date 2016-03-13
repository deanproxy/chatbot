require_relative 'command'

class Jokes < Command
    def respond
        if @params.length == 2
            @client.db.execute("insert into jokes(text) values(?)", [@params[1]])
            send("Okay, I saved that joke.", @is_pm)
        else
            jokes = ['Sorry, all out of jokes...']
            @client.db.execute("select text from jokes") do |row|
                jokes << row[0]
            end
            send(jokes[Random.rand(jokes.length-1)])
        end
    end
end

