require "./lib/commands/command"

class Jokes < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        jokes = ['Sorry, all out of jokes...']
        client.db.execute("select text from jokes") do |row|
            jokes << row[0]
        end
        client.send(room, jokes[Random.rand(jokes.length-1)])
    end
end

