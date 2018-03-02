# frozen_string_literal: true

class PrepareBranch
  def initialize(onto:, terminal: nil, environment: nil, logger: nil, styles: nil)
    @onto = onto
    @logger = logger || Logger.new
    @terminal = terminal || Terminal.new(logger: @logger)
    @environment = environment || Environment.new
    @styles = styles || Styles.new
  end

  def start
    while true do
      begin
        terminal.clear
        heading
        terminal.call :list_commits, onto: onto
        terminal.say 'Press a command key or ? for help', :hint
        result = terminal.wait_for_keypress
        handle_keypress result
      rescue Interrupt
        exit
      end
    end
  end

  private

  attr_reader :onto, :terminal, :environment, :logger, :styles

  def heading
    if environment.mid_rebase?
      terminal.write_line "❯ Rebasing #{environment.current_branch} onto #{onto}", :header_warning
      terminal.say ''
    else
      terminal.write_line "❯ #{environment.current_branch} => #{onto} | #{terminal.capture(:count_commits, onto: onto)} commits, #{terminal.capture(:count_files, onto: onto)} files", :header
      terminal.say ''
    end
  end

  def handle_keypress key
    case Command.for_key(key)
    when :begin_rebase
      terminal.call :begin_rebase, onto: onto
    when :show_diff
      sha = terminal.ask 'Enter a SHA', autocomplete_strategy: [:sha, { onto: onto }]
      terminal.clear
      terminal.call :show, sha: sha
      terminal.prompt_to_continue
    when :sum_diff
      start_sha = terminal.ask 'Enter the start SHA', autocomplete_strategy: [:sha, { onto: onto }]
      end_sha = terminal.ask 'Enter the end SHA', autocomplete_strategy: [:sha, { onto: onto }]
      terminal.clear
      terminal.call :sum_diff, start_sha: start_sha, end_sha: end_sha
      terminal.prompt_to_continue
    when :quit
      exit
    end
  end
end