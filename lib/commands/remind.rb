require './commands/command'

class Remind < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        if @params.length == 5
            # Don't allow reminders to self.
            if @params[0] == client.config['hipchat']['botname']
                client.send(room, "I'm sorry, I can't set reminders for myself.")
                return
            end
            nick = params[0]

            # Transform certain nouns so it sounds appropriate
            # when sending the reminder.
            message = @params[2]
            if @params[1]
                case @params[1].downcase
                when /^(he|she)$/
                    message = "you #{@params[2]}"
                when /^(he\'s|she\'s)$/
                    message = "you're #{@params[2]}"
                else
                    term = @params[2]
                end
            end

            rtime = parse_time(@params[3], @params[4])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            client.db.execute('insert into reminders(jid, time, text, room) values(?, ?, ?, ?)',
                             [nick, rtime.to_s, message, room])
            text = "Okay. I've set a reminder `#{message}` at #{readable_time}"
            client.send(room, text)
        else
            rtime = parse_time(@params[1], @params[2])
            jid = client.users[nick]['jid']
            mention = client.users[nick]['mention']
            client.db.execute("insert into reminders (jid, time, text) values(?, ?, ?)",
                      [jid.to_s, rtime.to_s, @params[0]])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            text = "Okay. I've set a reminder for you to #{@params[0]} at #{readable_time}"
            client.send(room, text, mention)
        end
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

