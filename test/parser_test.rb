require 'minitest/autorun'

require_relative '../lib/commands/command_parser'
require_relative '../lib/commands/build'
require_relative '../lib/commands/remind'
require_relative '../lib/commands/meme'
require_relative '../lib/commands/default'


class ParserTest < MiniTest::Test
    def setup
    end

    def teardown
    end

    def test_parser
        a = CommandParser::parse("do something stupid")
        assert_instance_of(Default, a)

        a = CommandParser::parse("/meme take my money")
        refute_nil(a)
        assert_instance_of(Meme, a)
        a = CommandParser::parse("make meme take my money")
        refute_nil(a)
        assert_instance_of(Meme, a)

        a = CommandParser::parse('/build MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('start build for MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('meow start build for MEOW-MIX')
        assert_instance_of(Default, a)
        a = CommandParser::parse('meow /start build for MEOW-MIX')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/status MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('get build status for MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('build status for MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('meow /status MEOW-MIX')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/alias meow MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('alias build meow MEOW-MIX')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('meow /alias meow MEOW-MIX')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/joke')
        refute_nil(a)
        assert_instance_of(Jokes, a)
        a = CommandParser::parse('tell me a joke')
        refute_nil(a)
        assert_instance_of(Jokes, a)
        a = CommandParser::parse('tell me another joke')
        refute_nil(a)
        assert_instance_of(Jokes, a)
        a = CommandParser::parse('tell me a /joke')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/deploy meow')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('deploy build meow')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('meow /deploy meow')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/remind me to pee in 1 minute')
        refute_nil(a)
        assert_instance_of(Remind, a)
        a = CommandParser::parse('remind me to pee in 1 minute')
        refute_nil(a)
        assert_instance_of(Remind, a)
        a = CommandParser::parse('/remind @bob to pee in 1 minute')
        refute_nil(a)
        assert_instance_of(Remind, a)
        a = CommandParser::parse('stuff remind @bob to pee in 1 minute')
        assert_instance_of(Default, a)

        a = CommandParser::parse('/watch meow')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('watch build meow')
        refute_nil(a)
        assert_instance_of(Build, a)
        a = CommandParser::parse('what watch build meow')
        assert_instance_of(Default, a)

        a = CommandParser::parse('hi')
        refute_nil(a)
        assert_instance_of(Salute, a)
        a = CommandParser::parse('i love you')
        refute_nil(a)
        assert_instance_of(Salute, a)

        a = CommandParser::parse('help')
        refute_nil(a)
        assert_instance_of(Help, a)
        a = CommandParser::parse('/help')
        refute_nil(a)
        assert_instance_of(Help, a)
        a = CommandParser::parse('meow help')
        assert_instance_of(Default, a)
    end
end
