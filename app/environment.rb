class Environment
  def initialize(terminal: nil)
    @terminal = terminal || Terminal.new
  end

  def current_branch
    @current_branch ||= terminal.capture :current_branch
  end

  private

  attr_reader :terminal
end