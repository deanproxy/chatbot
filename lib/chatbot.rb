#!/usr/bin/env ruby
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'xmpp4r/roster'
require 'yaml'
require 'sqlite3'
require 'logger'
require 'optparse'

require_relative 'commands/command_parser'
require_relative 'commands/remind'

class Bot
    attr_reader :config, :users, :db, :log

    def initialize(options)
        @config = YAML::load_file(options[:config] || 'config.yml')
        @connection_dead = false
        @nick = @config['xmpp']['nick']
        @botname = @config['xmpp']['botname']
        @users = {}
        @rooms = {}
        @db = SQLite3::Database.new(@config['database']['name'])
        @log = Logger.new('chatbot.log')
    end

    def lookup_room(room)
        found = nil
        @config['xmpp']['rooms'].each do |k, v|
            m = /(\d+)_(.+)/.match(k)
            if m 
                name = m[2].gsub('_', ' ')
                if name.downcase == room.downcase
                    found = k
                    break
                end
            end
        end
        return found
    end

    def respond(text, nick, time, room=nil)
        is_pm = room == nil

        match = /^(?:room|channel)? (.+);(?:\s)?(.+)?/.match(text)
        if match
            room = lookup_room($1)
            if !room 
                send_message(nick, "Sorry, I can't post anything to that room because I'm not subscribed to it.")
                return
            end
            text = $2
        end

        begin
            cmd = CommandParser.parse(text)
            if cmd
                cmd.set_attributes(self, time, nick, room, text, is_pm)
                cmd.respond
            end
        rescue => e
            @log.fatal(e.message)
            @log.fatal(e.backtrace)
            @connection_dead = true
        end
    end

    def connect
        @client = Jabber::Client.new(@config['xmpp']['username'])

        @client.connect(@config['xmpp']['server'])
        @client.auth(@config['xmpp']['password'])
        @client.send(Jabber::Presence.new.set_type(:available))

        @roster = Jabber::Roster::Helper.new(@client)
        @roster.add_subscription_callback do |m|
            @users[m.name] = {
                'jid' => m.jid,
                'mention' => m.attributes['mention_name'],
                'email' => m.attributes['email']
            }
        end

        @config['xmpp']['rooms'].each do |room|
            @rooms[room] = Jabber::MUC::SimpleMUCClient.new(@client)
            @rooms[room].join("#{room}@#{@config['xmpp']['conf']}/#{@config['xmpp']['nick']}", 
                      nil, {:history => false})
            @rooms[room].on_message do |time, nick, text|
                t = (time || Time.new).strftime("%I:%M")
                # Make sure they're talking to us.
                if nick != @config['xmpp']['nick'] && 
                    (/^#{@botname} (.*)/.match(text) || /^(\/.*)/.match(text))
                    respond($1, nick, t, room)
                end
            end
        end

        @client.add_message_callback do |mesg|
            begin
                if mesg.body and mesg.body.length
                    respond(mesg.body, mesg.from, Time.new.strftime("%I:%M"))
                end
            rescue => e
                @log.fatal(e.message)
                @log.fatal(e.backtrace)
                @connection_dead = true
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

    def send_message(nick, message)
        mess = Jabber::Message.new
        mess.to = nick
        mess.from = @config['xmpp']['username']
        mess.body = message
        mess.set_type(:chat)
        @client.send(mess)
    end

    def send(room, text, mention=nil)
        if mention 
            text = "@#{mention} #{text}"
        end
        
        @rooms[room].send(Jabber::Message.new(room, text))
    end

    def run
        @log.info("Running Bot...")

        Thread.start {
            loop do
                if @connection_dead
                    if @client
                        @client.close
                    end
                    exit
                end
                Remind::check_reminders(self)
                sleep(1)
            end
        }.join
    end
end

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: bot --config=configfile"
	opts.on("-c", "--config", "Location of your YML config file.") do |v|
        options[:config] = v
    end
    opts.on('-d', '--debug', "Debugging. Won't fork") do |v|
        options[:debug] = true
    end
end

# if options[:debug]
    # pid = fork {
        # b = Bot.new(options)
        # b.connect.run
    # }
    # File.open("bot.pid", "w") do |f|
        # f.write(pid)
    # end
# else
    b = Bot.new(options)
    b.connect.run
# end
