require 'net/http'
require 'json'

require_relative 'command'

def get_build_alias(db, build_alias)
    bamboo_id = nil
    db.execute("select alias_val from aliases where alias_key=?", build_alias.upcase) do |row|
        bamboo_id = row[0]
    end

    return bamboo_id
end


def get(url, username, password)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept'] = 'application/json'
    req.basic_auth(username, password)

    return Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
end

def post(url, username, password)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Accept'] = 'application/json'
    req.basic_auth(username, password)

    return Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
end

class Build < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        if not client.config.has_key?('bamboo')
            client.send(room, "I'm sorry, but I'm not configured to use Bamboo. Check my config.")
            return
        end
            
        config = client.config['bamboo']
        case @params['type'].downcase
        when 'build'
            build(client, room, time, nick, text)
        when 'deploy'
            deploy(client, room, time, nick, text)
        when 'watch'
            watch(client, room, time, nick, text)
        when 'status'
            status(client, room, time, nick, text)
        when 'alias'
            make_alias(client, room, time, nick, text)
        when 'show aliases'
            show_alias(client, room, time, nick, text)
        else
            client.send(room, "I'm not sure what you want me to do...'")
        end
    end

private
    def deploy(client, room, time=nil, nick=nil, text=nil)
        client.send(room, "I can't do this yet. My owner is trying to teach me how to do this. Sorry.")
    end

    def build(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        a = get_build_alias(client.db, @params['buildkey'])
        if !a
            a = @params['buildkey']
        end
        url = "#{config['url_base']}/queue/#{a}?executeAllStages=True"
        r = post(url, config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == "200"
            client.send(room, "Okay. I started a build for #{@params['buildkey']}. I'll keep an eye on it for you.")
            new_params = ["#{a}-#{j['buildNumber']}"]
            watch(client, room, time, nick, text)
        else
            client.send(room, "Oops. Couldn't run that build for some reason. Response from build server was:")
            client.send(room, "/code #{j['message']}")
        end
    end

    def watch(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        build_key = @params['buildkey'].match('(\w+-\w+)-(\w+)')
        if build_key
            plan,build_id = build_key[1,build_key.length]
        else
            client.send(room, "Parse error. You sent me: #{@params['buildkey']}")
            return
        end

        r = get("#{config['url_base']}/result/#{plan.upcase}/#{build_id}", config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == '404'
            client.send(room, "I'm sorry, I can't watch that build. Here's the reason: #{j['message']}")
        else
            Thread.start do
                _watch(client, room, plan.upcase, build_id)
            end
        end
    end

    def status(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        key = get_build_alias(client.db, @params['buildkey'])
        if !key
            key = @params['buildkey']
        end
        result = _get_latest_result(config, key)
        if result
            emoticon = "(greendot)"
            if result['state'] == 'Failed'
                light = "(reddot)"
            end
            id = result['id']
            state = result['state']
            client.send(room, "#{emoticon} The latest build for #{@params['buildkey']} was #{state} (build ID #{id})")
        else
            client.send(room, "I'm sorry, I couldn't find a build with the alias or key of #{@params['buildkey']}")
        end
    end

    def make_alias(client, room, time=nil, nick=nil, text=nil)
        client.db.execute("insert into aliases (alias_key, alias_val) values(?,?)", 
                   [@params['alias'].upcase, @params['buildkey'].upcase])
        client.send(room, "Okay. Saved a build alias of #{@params['alias'].upcase} -> #{@params['buildkey'].upcase}")
    end

    def show_alias(client, room, time=nil, nick=nil, text=nil)
        client.db.execute("select alias_key, alias_val from aliases") do |row|
            client.send(room, "#{row[0]} -> #{row[1]}")
        end
    end

    def _get_latest_result(config, project)
        response = nil

        url = "#{config['url_base']}/result/#{project}"
        r = get(url, config['username'], config['password'])
        if r.code == '200'
            json = JSON.parse(r.body)
            j = json['results']['result'][0]
            response = {
                'id' => j['number'], 
                'state' => j['buildState']
            }
        end

        return response
    end


    def _watch(client, room, plan, build_id)
        config = client.config['bamboo']
        loop do
            r = get("#{config['url_base']}/result/#{plan}/#{build_id}", config['username'], config['password'])
            if r.code == '200'
                j = JSON.parse(r.body)
                if j['state'] == "Unknown"
                    percentage = j['progress']['percentageCompletedPretty']
                    client.send(room, "The build I'm watching (#{plan}-#{build_id}) is #{percentage} complete.")
                    sleep(60)
                else
                    emoticon = "(greendot)"
                    state = j['state']
                    if j['state'] == 'Failed'
                        light = "(reddot)"
                    end
                    client.send(room, "#{emoticon} The build #{plan}-#{build_id} is finished. It's status is: #{state}")
                    break
                end
            end
        end
    end
end

