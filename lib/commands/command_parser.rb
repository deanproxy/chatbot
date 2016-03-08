require 'logger'

require_relative 'salute'
require_relative 'jokes'
require_relative 'build'
require_relative 'default'
require_relative 'help'
require_relative 'die'
require_relative 'remind'
require_relative 'meme'

$commands = {
    "^(hey|hi|hello|what's up|sup|yo|i love you|welcome back)$" => Salute,
    '^(?:^\/)?help$' => Help,
    '^(?:please\s)?die$' => Die,
    "^(?:(?:tell me a)?(?:nother)?(?: )|(?:^\/))joke" => Jokes,
    '^(?:\w+\s)?build (?<type>status) for (?<buildkey>\w+(?:[-\w+])?)' => Build,
    '^(?:^\/)?(?<type>alias) (?:build )?(?<alias>\w+(?:[-\w+])?) (?<buildkey>\w+(?:-\w+)?)' => Build,
    '^(?<type>show aliases)' => Build,
    '^(?:start )?(?:^\/)?(?<type>build) (?:for )?(?<buildkey>\w+(?:[-\w+])?)' => Build,
    '^(?:^\/)?(?<type>watch) (?:build )?(?<buildkey>\w+(?:[-\w+]+))' => Build,
    '^(?:^\/)?(?<type>deploy) (?:build )?(?<buildkey>\w+(?:[-\w+]))' => Build,
    '^(?:^\/)?remind me (?:of|to)? (.*) (at|on|in) (.*)' => Remind,
    '^(?:^\/)?remind (\@\w+)(?:\s(?:of|about|to|that?))?(?:\s(he|she|his|her|she\'s|he\'s))? (.*) (at|in|on) (.*)' => Remind,
    '^(?:(?:make )?(?:\/)?meme)(?: (.*)?)?' => Meme,
    '^(?:^\/)?quote' => Default
}


module CommandParser
    def CommandParser.parse(text)
        cmd = nil
        log = Logger.new('hipbot.log')
        $commands.each do |key, clazz|
            match = text.downcase.match(key)
            if match
                log.debug("Text matched was: #{text}")
                log.debug("Matched string: #{match[0]}. Params are: #{match[1,match.length]}")
                cmd = clazz.new(match)
                log.debug("The class we got from this match is: #{cmd.class}")
                break
            end
        end
        return cmd
    end
end

