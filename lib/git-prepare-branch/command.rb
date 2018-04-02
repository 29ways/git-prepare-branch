# frozen_string_literal: true

module GitPrepareBranch
  class Command
    attr_reader :key, :name, :command, :options

    def initialize(key, name, command, options={})
      @key = key
      @name = name
      @command = command
      @options = options
    end

    def call(context)
      inputs = capture_inputs(context)
      run_proc(context, inputs) if command.is_a?(Proc)
      run_as_shell_command(context, inputs) if command.is_a?(String)
      context.terminal.prompt_to_continue if options[:prompt_to_continue]
    end

    def description
      options[:description]
    end

    private

    def capture_inputs(context)
      return {} unless options[:input]
      options[:input].each_with_object({}) do |(key, value), object|
        object[key] = context.terminal.ask value[:prompt], autocomplete_strategy: [value[:autocomplete_strategy], context.variables]
      end
    end

    def run_as_shell_command(context, inputs)
      context.terminal.call format(
        command,
        context.variables.to_h.merge(inputs)
      )
    end

    def run_proc(context, inputs)
      command.call(context, inputs)
    end
  end
end