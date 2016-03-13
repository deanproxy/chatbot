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
    def respond
        if not @client.config.has_key?('bamboo')
            send("I'm sorry, but I'm not configured to use Bamboo. Check my config.", @is_pm)
            return
        end
            
        config = client.config['bamboo']
        case @params['type'].downcase
        when 'build'
            build
        when 'deploy'
            deploy
        when 'watch'
            watch
        when 'status'
            status
        when 'alias'
            make_alias
        when 'show aliases'
            show_alias
        else
            send("I'm not sure what you want me to do...'", @is_pm)
        end
    end

private
    def deploy
        send("I can't do this yet. My owner is trying to teach me how to do this. Sorry.", @is_pm)
    end

    def build
        config = @client.config['bamboo']
        a = get_build_alias(@client.db, @params['buildkey'])
        if !a
            a = @params['buildkey']
        end
        url = "#{config['url_base']}/queue/#{a}?executeAllStages=True"
        r = post(url, config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == "200"
            send("Okay. I started a build for #{@params['buildkey']}. I'll keep an eye on it for you.")
            new_params = ["#{a}-#{j['buildNumber']}"]
            watch
        else
            send("Oops. Couldn't run that build for some reason. Response from build server was:", @is_pm)
            send("/code #{j['message']}", @is_pm)
        end
    end

    def watch
        config = @client.config['bamboo']
        build_key = /(\w+-\w+)-(\w+)/.match(@params['buildkey'])
        if build_key
            plan,build_id = build_key[1,build_key.length]
        else
            send("Parse error. You sent me: #{@params['buildkey']}", @is_pm)
            return
        end

        r = get("#{config['url_base']}/result/#{plan.upcase}/#{build_id}", config['username'], config['password'])
        j = JSON.parse(r.body)
        if r.code == '404'
            send("I'm sorry, I can't watch that build. Here's the reason: #{j['message']}", @is_pm)
        else
            Thread.start do
                _watch(plan.upcase, build_id)
            end
        end
    end

    def status
        config = @client.config['bamboo']
        key = get_build_alias(@client.db, @params['buildkey'])
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
            send("#{emoticon} The latest build for #{@params['buildkey']} was #{state} (build ID #{id})")
        else
            send("I'm sorry, I couldn't find a build with the alias or key of #{@params['buildkey']}", @is_pm)
        end
    end

    def make_alias
        @client.db.execute("insert into aliases (alias_key, alias_val) values(?,?)", 
                   [@params['alias'].upcase, @params['buildkey'].upcase])
        send("Okay. Saved a build alias of #{@params['alias'].upcase} -> #{@params['buildkey'].upcase}", @is_pm)
    end

    def show_alias
        @client.db.execute("select alias_key, alias_val from aliases") do |row|
            send("#{row[0]} -> #{row[1]}", @is_pm)
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


    def _watch(plan, build_id)
        config = @client.config['bamboo']
        loop do
            r = get("#{config['url_base']}/result/#{plan}/#{build_id}", config['username'], config['password'])
            if r.code == '200'
                j = JSON.parse(r.body)
                if j['state'] == "Unknown"
                    percentage = j['progress']['percentageCompletedPretty']
                    send("The build I'm watching (#{plan}-#{build_id}) is #{percentage} complete.")
                    sleep(60)
                else
                    emoticon = "(greendot)"
                    state = j['state']
                    if j['state'] == 'Failed'
                        light = "(reddot)"
                    end
                    send("#{emoticon} The build #{plan}-#{build_id} is finished. It's status is: #{state}")
                    break
                end
            end
        end
    end
end

