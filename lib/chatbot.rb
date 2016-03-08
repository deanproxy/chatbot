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
                if nick != @config['xmpp']['nick'] && (text.match("^#{@botname} (.*)") || text.match("^(\/.*)"))
                    begin
                        cmd = CommandParser.parse($1)
                        if cmd
                            cmd.respond(self, room, t, nick, $1)
                        end
                    rescue => e
                        @log.fatal(e.message)
                        @log.fatal(e.backtrace)
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

    def send_message(message)
        @client.send(message)
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
end

pid = fork {
    b = Bot.new(options)
    b.connect.run
}
File.open("bot.pid", "w") do |f|
    f.write(pid)
end

