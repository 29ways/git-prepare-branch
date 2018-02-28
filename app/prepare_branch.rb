# frozen_string_literal: true

class PrepareBranch
  def initialize(onto:, terminal: nil, environment: nil, logger: nil)
    @onto = onto
    @logger = logger || Logger.new
    @terminal = terminal || Terminal.new(logger: @logger)
    @environment = environment || Environment.new
  end

  def start
    while true do
      begin
        terminal.clear
        terminal.say heading
        terminal.call :list_commits, onto: onto
        result = terminal.ask ''
        handle_keypress result
        terminal.say result
      rescue Interrupt
        exit
      end
    end
  end

  private

  attr_reader :onto, :terminal, :environment, :logger

  def heading
    terminal.say "Rebasing #{environment.current_branch} on to #{onto}"
  end

  def handle_keypress key
    case key
    when 'r'
      terminal.call :begin_rebase, onto: onto
      terminal.prompt_to_continue
    when 'd'
      sha = terminal.ask 'Enter a SHA', autocomplete_strategy: [:sha, { onto: onto }]
      terminal.clear
      terminal.call :show, sha: sha
      terminal.prompt_to_continue
    when 's'
      start_sha = terminal.ask 'Enter the start SHA', autocomplete_strategy: [:sha, { onto: onto }]
      end_sha = terminal.ask 'Enter the end SHA', autocomplete_strategy: [:sha, { onto: onto }]
      terminal.clear
      terminal.call :sum_diff, start_sha: start_sha, end_sha: end_sha
      terminal.prompt_to_continue
    when 'q'
      exit
    end
  end
end