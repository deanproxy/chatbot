require 'salute'
require 'jokes'
require 'build'
require 'default'
require 'help'
require 'die'
require 'remind'

$commands = {
    "(hey|hi|hello|what's up|sup|yo|i love you)" => Salute,
    'help' => Help,
    'die' => Die,
    "tell me a(?:nother)? joke" => Jokes,
    '(?:\w+\s)?build status for (\w+(?:[-\w+])?)' => BuildStatus,
    'alias build (\w+(?:[-\w+])?) (\w+(?:-\w+)?)' => BuildAlias,
    'show aliases' => BuildShowAlias,
    'start build for (\w+(?:[-\w+])?)' => BuildStart,
    'watch build (\w+(?:[-\w+]+))' => BuildWatch,
    'deploy build (\w+(?:[-\w+]))' => BuildDeploy,
    'remind me (?:of|to)? (.*?) (?:at|on)? (.*)' => Remind,
    '.*' => Default
}


module CommandParser
    def CommandParser.parse(text)
        cmd = nil
        $commands.each do |key, clazz|
            match = text.downcase.match(key)
            if match
                cmd = clazz.new(match[1, match.length])
                break
            end
        end
        return cmd
    end
end

