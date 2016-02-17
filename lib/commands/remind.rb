require "./lib/commands/command"

class Remind < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        if @params.length == 4
            # This is probably a room reminder
            if @params[0] == 'the room' || @params[0] == 'everyone'
                nick = '@all'
            else
                nick = @params[0]
            end
            rtime = parse_time(@params[2], @params[3])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            client.db.execute('insert into reminders(jid, time, text, room) values(?, ?, ?, ?)',
                             [nick, rtime.to_s, @params[1], room])
            text = "Okay. I've set a reminder `#{@params[1]}` at #{readable_time}"
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

    def self.check_reminders(client)
        client.db.execute('select id,jid,time,text,room from reminders where time <= ?', [DateTime.now.to_s]) do |row|
            if row[4]
                client.send(row[4], "Hey, #{row[1]}, #{row[3]}")
            else
                mess = Jabber::Message.new
                mess.to = row[1]
                mess.from = @config['hipchat']['username']
                mess.body = "Hey, #{row[3]}"
                mess.set_type(:chat)
                client.send(mess)
            end
            client.db.execute("delete from reminders where id = ?", [row[0]])
            client.log.info("Sent a reminder to #{row[1]}")
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

