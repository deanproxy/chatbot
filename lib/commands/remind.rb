require_relative 'command'

class Remind < Command
    def self.check_reminders(client)
        client.db.execute('select id,jid,time,:ext,room from reminders where time <= ?', [DateTime.now.to_s]) do |row|
            if row[4]
                client.send(row[4], "Hey, #{row[1]}, #{row[3]}")
            else
                client.send_message(row[1], "Hey, #{row[3]}")
            end
            client.db.execute("delete from reminders where id = ?", [row[0]])
            client.log.info("Sent a reminder to #{row[1]}")
        end
    end

    def transform_language
        noun = @params[2]
        message = @params[3]

        if noun
            # Tranform noun
            case noun.downcase
            when /^(he|she)$/
                noun = "you "
            when /^(he\'s|she\'s)$/
                noun = "you're "
            end
        end

        # Transform verb
        matches = /([A-Za-z']+) (.*)/.match(@params[3])
        verb = ''
        if matches
            verb = matches[1]
            case verb
            when 'needs'
                verb = 'need '
            when 'wants'
                verb = 'want '
            when 'has'
                verb = 'have '
            when 'is'
                verb = 'are '
            when "hasn't"
                verb = "haven't "
            else
                verb = "#{verb} "
            end
            message = "#{noun}#{verb}#{matches[2]}"
        else
            message = "#{noun}#{@params[3]}"
        end

        return message
    end


    def respond
        if @params.length > 4
            # Don't allow reminders to self.
            if @params[1] == @client.config['xmpp']['botname']
                send("I'm sorry, I can't set reminders for myself.", @is_pm)
                return
            end

            # Transform certain words so it sounds appropriate when sending the reminder.
            message = transform_language()
            rtime = parse_time(@params[4], @params[5])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            @client.db.execute('insert into reminders(jid, time, text, room) values(?, ?, ?, ?)',
                             [@params[1], rtime.to_s, message, @room])
            text = "Okay. I've set a reminder `#{message}` at #{readable_time}"
            send(text, @is_pm)
        else
            rtime = parse_time(@params[2], @params[3])
            mention = ''
            if @client.users.has_key?(@nick)
                old_nick = @nick
                @nick = @client.users[old_nick]['jid']
                mention = " #{@client.users[old_nick]['mention']}"
            end
            @client.db.execute("insert into reminders (jid, time, text) values(?, ?, ?)",
                      [@nick.to_s, rtime.to_s, @params[1]])
            readable_time = rtime.strftime("%m/%d/%Y %l:%M%p")
            text = "Okay#{mention}. I've set a reminder for you to `#{@params[1]}` at #{readable_time}"
            send(text, @is_pm)
        end
    end

private
    def parse_time(qualifier, time)
        date = nil
        if qualifier.downcase == 'in'
            match = /([0-9]+) (\w+)/.match(time)
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

