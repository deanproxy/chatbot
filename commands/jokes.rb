require 'command'
require 'sqlite3'

class Jokes < Command
    def respond(client, time=nil, nick=nil, text=nil)
        jokes = ['Sorry, all out of jokes...']
        db = SQLite3::Database.new(client.config['database']['name'])
        db.execute("select text from jokes") do |row|
            jokes << row[0]
        end
        client.send(jokes[Random.rand(jokes.length-1)])
    end
end

