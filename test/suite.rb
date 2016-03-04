require 'minitest/reporters'
require 'minitest/autorun'
require_relative 'remind_test.rb'
require_relative 'parser_test.rb'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new({color:true})]
