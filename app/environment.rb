class Environment
  def initialize(terminal: nil)
    @terminal = terminal || Terminal.new
  end

  def current_branch
    @current_branch ||= terminal.capture :current_branch
  end

  def mid_rebase?
    terminal.capture(:check_if_mid_rebase) == '1'
  end

  private

  attr_reader :terminal
end