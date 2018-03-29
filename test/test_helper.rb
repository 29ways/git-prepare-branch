require 'minitest/spec'
require "minitest/autorun"

$: << File.expand_path('./app')

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new