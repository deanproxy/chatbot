#!/usr/bin/env ruby -I . -I commands
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'xmpp4r/roster'
require 'yaml'
require 'sqlite3'

require 'commands/command_parser'

class Bot

    def initialize
        load_config
        @connection_dead = false
        @nick = @config['hipchat']['nick']
        @botname = @config['hipchat']['botname']
        @users = {}
        @rooms = {}
        @db = SQLite3::Database.new(@config['database']['name'])
    end

    def config
        return @config
    end

    def users
        return @users
    end

    def db
        return @db
    end

    def connect
        @client = Jabber::Client.new(@config['hipchat']['username'])

        @client.connect(@config['hipchat']['server'])
        @client.auth(@config['hipchat']['password'])
        @client.send(Jabber::Presence.new.set_type(:available))

        @roster = Jabber::Roster::Helper.new(@client)
        @roster.add_subscription_callback do |m|
            @users[m.name] = {
                'jid' => m.jid,
                'mention' => m.attributes['mention_name'],
                'email' => m.attributes['email']
            }
        end

        @config['hipchat']['rooms'].each do |room|
            @rooms[room] = Jabber::MUC::SimpleMUCClient.new(@client)
            @rooms[room].join("#{room}@#{@config['hipchat']['conf']}/#{@config['hipchat']['nick']}", 
                      nil, {:history => false})
            @rooms[room].on_message do |time, nick, text|
                t = (time || Time.new).strftime("%I:%M")
                # Make sure they're talking to us.
                if text.match("#{@botname} (.*)")
                    begin
                        cmd = CommandParser.parse($1)
                        cmd.respond(self, room, t, nick, text)
                    rescue Exception => e
                        puts "Exception caught: #{e.message}"
                        puts e.backtrace
                        @connection_dead = true
                    end
                end
            end
        end



        # Load initial roster
        @roster.get_roster()
        @roster.wait_for_roster()
        @roster.items.each do |k,v|
            @users[v.attributes['name']] = {
                'jid' => v.jid,
                'mention' => v.attributes['mention_name'],
                'email' => v.attributes['email']
            }
        end

        self
    end

    def send(room, text, mention=nil)
        if mention 
            text = "@#{mention} #{text}"
        end
        
        @rooms[room].send(Jabber::Message.new(room, text))
    end

    def run
        warn "Running Bot..."

        Thread.start {
            loop do
                if @connection_dead
                    if @client
                        @client.close
                    end
                    exit
                end
                check_reminders
                sleep(1)
            end
        }.join
    end

private
    def load_config
        @config = YAML.load_file('config.yml')
    end

    def check_reminders
        @db.execute('select id,jid,time,text from reminders where time <= ?', [DateTime.now.to_s]) do |row|
            mess = Jabber::Message.new
            mess.to = row[1]
            mess.from = @config['hipchat']['username']
            mess.body = "Hey, you wanted me to remind you: #{row[3]}"
            mess.set_type(:chat)
            @client.send(mess)
            @db.execute("delete from reminders where id = ?", [row[0]])
        end
    end

end

b = Bot.new
b.connect.run
