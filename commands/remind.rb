require 'command'

class Remind < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        rtime = parse_time(@params[1], @params[2])
        jid = client.users[nick]['jid']
        mention = client.users[nick]['mention']
        client.db.execute("insert into reminders (jid, time, text) values(?, ?, ?)",
                  [jid.to_s, rtime.to_s, @params[0]])
        readable_time = rtime.strftime("%m/%d/%Y %l:%M:%S%p")
        text = "Okay. I've set a reminder for you to #{@params[0]} at #{readable_time}"
        client.send(room, text, mention)
    end

private
    def parse_time(qualifier, time)
        date = nil
        if qualifier.downcase == 'in'
            match = time.match('([0-9]+) (\w+)')
            if match
                time = Time.now
                number = match[1].to_i
                case match[2]
                when /minute[s]?/
                    time = time + (number * 60)
                when /hour[s]?/
                    time = time + (number * (60 * 60))
                when /day[s]?/
                    time = time + (number * (60 * 60 * 24))
                when /month[s]?/
                    time = time + (number * (60 * 60 * 24 * 30))
                when /year[s]?/
                    time = time + (number * (60 * 60 * 24 * 365))
                end
                date = DateTime.parse(time.to_s)
            end
        else
            date = DateTime.parse(time)
        end
        return date
    end

end

