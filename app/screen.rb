# frozen_string_literal: true

require_relative 'command'
require_relative 'command_keys'

class Screen
  attr_reader :name, :context
  attr_accessor :context, :title, :heading, :heading_style, :description, :display

  def initialize(name)
    @name = name
  end

  def add_command(key, name, command, options={})
    commands[key] = Command.new(key, name, command, options)
  end

  def commands
    @commands ||= {}
  end

  def handle_keypress key, context
    help if ['h', '?'].include?(key)
    exit if ['q', CommandKeys::CTRL_C, CommandKeys::CTRL_D].include?(key)
    return unless commands.keys.include?(key)
    commands[key].call(context)
  end

  def help
    terminal.clear
    terminal.say "DESCRIPTION"
    terminal.hr
    terminal.say "#{description}\n\n"
    terminal.say "COMMANDS"
    terminal.hr
    commands.each_with_object('') do |(key, command), result|
      terminal.say "#{key}   #{command.name.ljust(longest_command_name_length)}     #{command.description}"
      terminal.say "\n"
    end
    terminal.prompt_to_continue
  end

  def longest_command_name_length
    @longest_command_name_length ||= commands.collect{|(_, c)| c.name.length}.max
  end

  private

  def terminal
    context.terminal
  end
end