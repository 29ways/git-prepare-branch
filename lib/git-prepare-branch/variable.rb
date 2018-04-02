# frozen_string_literal: true

module GitPrepareBranch
  class Variable
    attr_reader :name, :context, :value, :capture

    def initialize(name, context:, value: nil, capture: nil)
      @name = name
      @context = context
      @capture = capture
      @value = calculate_value(value)
    end

    private

    def calculate_value(value)
      return context.terminal.capture(capture_with_variables_injected) unless capture.nil?
      return value.call(context) if value.kind_of? Proc
      value
    end

    def capture_with_variables_injected
      format(capture, context.variables.to_h)
    end
  end
end