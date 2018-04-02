require 'minitest/spec'
require "minitest/autorun"

$: << File.expand_path('./lib')

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require 'pry'