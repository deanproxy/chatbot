require_relative 'command'

class Remind < Command
    def self.check_reminders(client)
        client.db.execute('select id,jid,time,text,room from reminders where time <= ?', [DateTime.now.to_s]) do |row|
            if row[4]
                client.send(row[4], "Hey, #{row[1]}, #{row[3]}")
            else
                mess = Jabber::Message.new
                mess.to = row[1]
                mess.from = client.config['xmpp']['username']
                mess.body = "Hey, #{row[3]}"
                mess.set_type(:chat)
                client.send_message(mess)
            end
            client.db.execute("delete from reminders where id = ?", [row[0]])
            client.log.info("Sent a reminder to #{row[1]}")
        end
    end

    def respond(client, room, time=nil, nick=nil, text=nil)
        if @params.length == 6
            # Don't allow reminders to self.
            if @params[1] == client.config['xmpp']['botname']
                client.send(room, "I'm sorry, I can't set reminders for myself.")
                return
            end
            nick = params[1]

            # Transform certain nouns so it sounds appropriate
            # when sending the reminder.
            message = @params[3]
            noun = @params[2] || ''
            if noun.length
                case noun.downcase
                when /^(he|she)$/
                    noun = "you"
                when /^(he\'s|she\'s)$/
                    noun = "you're"
                end

                # Transform verb
                matches = @params[3].match("([A-Za-z']+) (.*)")
                verb = ''
                if matches
                    verb = matches[1]
                    case verb
                    when 'needs'
                        verb = 'need'
                    when 'wants'
                        verb = 'want'
                    when 'has'
                        verb = 'have'
                    when 'is'
                        verb = 'are'
                    when "hasn't"
                        verb = "haven't"
                    end
                    message = "#{noun} #{verb} #{matches[2]}"
                else
                    message = "#{noun}#{@params[3]}"
                end

            end

            rtime = parse_time(@params[4], @params[5])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            client.db.execute('insert into reminders(jid, time, text, room) values(?, ?, ?, ?)',
                             [nick, rtime.to_s, message, room])
            text = "Okay. I've set a reminder `#{message}` at #{readable_time}"
            client.send(room, text)
        else
            rtime = parse_time(@params[2], @params[3])
            jid = client.users[nick]['jid']
            mention = client.users[nick]['mention']
            client.db.execute("insert into reminders (jid, time, text) values(?, ?, ?)",
                      [jid.to_s, rtime.to_s, @params[1]])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            text = "Okay. I've set a reminder for you to `#{@params[1]}` at #{readable_time}"
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

