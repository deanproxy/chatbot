require './commands/command'
require 'net/http'

class Meme < Command
    def print_help(client, room)
        client.send(room, "/code Here are the memes I can do:\n" +
                   "* I don't always ___ but when I do ___\n" +
                   "* Yo dawg ___ so ___\n" +
                   "* One does not simply ___\n" +
                   "* take my money\n" +
                   "* Not sure if ___ or ___\n" +
                   "* What if I told you ___\n" +
                   "* Am I the only one around here ___\n" +
                   "* ___ Ain't nobody got time for that'")
    end

    def respond(client, room, time=nil, nick=nil, text=nil)
        # Meme ID's come from https://api.imgflip.com/caption_image
        # This should probably be more robust and stored in the db,
        # but I'm kinda lazy right now...
        @memes = {
            :interesting_man => 61532,
            :yodawg => 101716,
            :takemoney => 176908,
            :notsure => 61520,
            :onedoesnot => 61579,
            :matrix => 100947,
            :onlyone => 259680,
            :notime => 442575
        }

        meme_url = nil
        post_data = {
            :template_id => nil,
            :text0 => nil,
            :text1 => nil,
            :username => nil,
            :password => nil
        }

        case @params[0].downcase
        when 'help'
            print_help(client, room)
            return
        when /i don't always (.*) but when i do (.*)/
            post_data[:template_id] = @memes[:interesting_man]
            post_data[:text0] = "I don't always #{$1}"
            post_data[:text1] = "but when I do, #{$2}"
        when /yo dawg (.*) so (.*)/
            post_data[:template_id] = @memes[:yodawg]
            post_data[:text0] = "Yo Dawg, #{$1}"
            post_data[:text1] = "so #{$2}"
        when /one does not simply (.*)/
            post_data[:template_id] = @memes[:onedoesnot]
            post_data[:text0] = 'One does not simply'
            post_data[:text1] = $1
        when /take my money/
            post_data[:template_id] = @memes[:takemoney]
            post_data[:text0] = 'Shut up and'
            post_data[:text1] = 'take my money!'
        when /not sure if (.*) or (.*)/
            post_data[:template_id] = @memes[:notsure]
            post_data[:text0] = "Not sure if #{$1}"
            post_data[:text1] = "or #{$2}"
        when /what if i told you (.*)/
            post_data[:template_id] = @memes[:matrix]
            post_data[:text0] = "What if I told you"
            post_data[:text1] = $1
        when /am i then only one around here (.*)/
            post_data[:template_id] = @memes[:onlyone]
            post_data[:text0] = 'Am I the only one around here'
            post_data[:text1] = $1
        when /(.*) ain't nobody got time for that/
            post_data[:template_id] = @memes[:notime]
            post_data[:text0] = $1
            post_data[:text1] = "Ain't nobody got time for that!"
        end

        url = client.config['meme']['post_url']
        post_data[:username] = client.config['meme']['username']
        post_data[:password] = client.config['meme']['password']

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(post_data)
        response = http.request(request)
        if response.code == '200'
            data = JSON.parse(response.body)
            if data['success']
                meme_url = data['data']['url']
            else
                client.log.error("Tried to make meme, but got error: #{data['error_message']}")
            end
        else
            client.log.error("Tried to make meme, but got response: #{response.code}")
        end

        if meme_url
            client.send(room, meme_url)
        else
            client.send(room, "Sorry, I couldn't generate a meme for that.")
        end
    end
end
