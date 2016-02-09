require 'command'

class Remind < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        rtime = DateTime.parse(@params[1] + "EST")
        jid = client.users[nick]['jid']
        mention = client.users[nick]['mention']
        client.db.execute("insert into reminders (jid, time, text) values(?, ?, ?)",
                  [jid.to_s, rtime.to_s, @params[0]])
        readable_time = rtime.strftime("%m/%d/%Y %l:%M:%S%p EST")
        text = "Okay. I've set a reminder for you to #{@params[0]} at #{readable_time}"
        client.send(room, text, mention)
    end
end

