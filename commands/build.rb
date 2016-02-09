require 'command'
require 'net/http'
require 'json'

def get_build_alias(db, build_alias)
    bamboo_id = nil
    db.execute("select alias_val from aliases where alias_key=?", build_alias.upcase) do |row|
        bamboo_id = row[0]
    end

    return bamboo_id
end


def get(url, username, password)
    puts "Bamboo: Calling GET on #{url}"
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept'] = 'application/json'
    req.basic_auth(username, password)

    return Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
end

def post(url, username, password)
    puts "Bamboo: Calling GET on #{url}"
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Accept'] = 'application/json'
    req.basic_auth(username, password)

    return Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
end

class BuildWatch < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        build_key = @params[0].match('(\w+-\w+)-(\w+)')
        if build_key
            plan,build_id = build_key[1,build_key.length]
        else
            client.send(room, "Parse error. You sent me: #{@params[0]}")
            return
        end

        r = get("#{config['url_base']}/result/#{plan.upcase}/#{build_id}", config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == '404'
            client.send(room, "I'm sorry, I can't watch that build. Here's the reason: #{j['message']}")
        else
            Thread.start do
                watch(client, room, plan.upcase, build_id)
            end
        end
    end

private
    def watch(client, room, plan, build_id)
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

class BuildStart < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        a = get_build_alias(client.db, @params[0])
        if !a
            a = @params[0]
        end
        url = "#{config['url_base']}/queue/#{a}?executeAllStages=True"
        r = post(url, config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == "200"
            client.send(room, "Okay. I started a build for #{@params[0]}. I'll keep an eye on it for you.")
            new_params = ["#{a}-#{j['buildNumber']}"]
            watch = BuildWatch.new(new_params)
            watch.respond(client)
        else
            client.send(room, "Oops. Couldn't run that build for some reason. Response from build server was:")
            client.send(room, "/code #{j['message']}")
        end
    end
end

# Need to make this one work.
class BuildDeploy < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.send(room, "I can't do this yet. My owner is trying to teach me how to do this. Sorry.")
    end
end

class BuildStatus < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        config = client.config['bamboo']
        key = get_build_alias(client.db, @params[0])
        if !key
            key = @params[0]
        end
        result = get_latest_result(config, key)
        if result
            emoticon = "(greendot)"
            if result['state'] == 'Failed'
                light = "(reddot)"
            end
            id = result['id']
            state = result['state']
            client.send(room, "#{emoticon} The latest build for #{@params[0]} was #{state} (build ID #{id})")
        else
            client.send(room, "I'm sorry, I couldn't find a build with the alias or key of #{@params[0]}")
        end
    end

private
    def get_latest_result(config, project)
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

end

class BuildAlias < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.db.execute("insert into aliases (alias_key, alias_val) values(?,?)", 
                   [@params[0].upcase, @params[1].upcase])
        client.send(room, "Okay. Saved a build alias of #{@params[0].upcase} -> #{@params[1].upcase}")
    end
end

class BuildShowAlias < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.db.execute("select alias_key, alias_val from aliases") do |row|
            client.send(room, "#{row[0]} -> #{row[1]}")
        end
    end
end
