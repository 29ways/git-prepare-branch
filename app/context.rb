# frozen_string_literal: true

class Context
  attr_reader :terminal, :variables

  def initialize(terminal:, variables:)
    @terminal = terminal
    @variables = OpenStruct.new(variables)
  end
end
