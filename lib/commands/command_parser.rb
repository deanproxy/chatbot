require 'logger'

require "./lib/commands/salute"
require "./lib/commands/jokes"
require "./lib/commands/build"
require "./lib/commands/default"
require "./lib/commands/help"
require "./lib/commands/die"
require "./lib/commands/remind"

$commands = {
    "^(hey|hi|hello|what's up|sup|yo|i love you|welcome back)" => Salute,
    'help' => Help,
    '(?:please\s)?die' => Die,
    "tell me a(?:nother)? joke" => Jokes,
    '(?:\w+\s)?build status for (\w+(?:[-\w+])?)' => BuildStatus,
    'alias build (\w+(?:[-\w+])?) (\w+(?:-\w+)?)' => BuildAlias,
    'show aliases' => BuildShowAlias,
    'start build for (\w+(?:[-\w+])?)' => BuildStart,
    'watch build (\w+(?:[-\w+]+))' => BuildWatch,
    'deploy build (\w+(?:[-\w+]))' => BuildDeploy,
    'remind me (?:of|to)? (.*) (at|on|in) (.*)' => Remind,
    'remind (\@?\w+)(?:\sthat)? (.*) (at|on|in) (.*)' => Remind,
    '.*' => Default
}


module CommandParser
    def CommandParser.parse(text)
        cmd = nil
        log = Logger.new('hipbot.log')
        $commands.each do |key, clazz|
            match = text.downcase.match(key)
            if match
                log.debug("Matched string: #{match[0]}. Params are: #{match[1,match.length]}")
                cmd = clazz.new(match[1, match.length])
                break
            end
        end
        return cmd
    end
end

