# frozen_string_literal: true

require 'ostruct'

require_relative 'logger'
require_relative 'configurator'
require_relative 'context'
require_relative 'terminal'
require_relative 'variable'

module GitPrepareBranch
  class App
    attr_reader :logger

    attr_accessor :title, :router

    def initialize(logger: nil)
      @logger = logger || Logger.new
    end

    def add_event_handler(event, &block)
      event_handlers[event] ||= []
      event_handlers[event] << block
    end

    def add_screen screen
      screen.context = context
      screens[screen.name] = screen
    end

    def add_variable name, capture: nil, value: nil
      context.variables[name] = Variable.new(name, context: context, capture: capture, value: value).value
    end

    def configure(&block)
      Configurator.new(self).apply(&block)
      self
    end

    def context
      @context ||= Context.new(
        terminal: terminal,
        variables: {}
      )
    end

    def current_screen
      screens[current_screen_name]
    end

    def current_screen_name
      router.call(context)
    end

    def screens
      @screens ||= {}
    end

    def start(variables = [])
      variables.each { |name, args| add_variable(name, args) }
      trigger :load
      while true do
        begin
          terminal.clear
          trigger :display
          terminal.write_line format(current_screen.heading, context.variables.to_h), current_screen.heading_style
          terminal.call current_screen.display, context.variables.to_h
          terminal.say 'Press a command key or ? for help', :hint
          begin
            result = terminal.wait_for_keypress
            current_screen.handle_keypress result, context
          rescue Interrupt
          end
        rescue Interrupt
          exit
        end
      end
    end

    def terminal
      @terminal ||= Terminal.new(logger: logger)
    end

    def trigger event
      return unless event_handlers[event]

      event_handlers[event].each do |block|
        block.call(context)
      end
    end

    class << self
      def configure(*options, &block)
        self.new(*options).configure(&block)
      end
    end

    private

    def event_handlers
      @event_handlers ||= {}
    end
  end
end