# frozen_string_literal: true

class PrepareBranch
  def initialize(onto:, terminal: nil, environment: nil, logger: nil, styles: nil)
    @onto = onto
    @logger = logger || Logger.new
    @terminal = terminal || Terminal.new(logger: @logger)
    @environment = environment || Environment.new(terminal: @terminal)
    @styles = styles || Styles.new
  end

  def start
    while true do
      begin
        terminal.clear
        heading
        terminal.call :list_commits, onto: onto, file_filter: terminal.file_filter
        terminal.say 'Press a command key or ? for help', :hint
        result = terminal.wait_for_keypress
        if environment.mid_rebase?
          handle_keypress_mid_rebase result
        else
          handle_keypress result
        end
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
      terminal.write_line default_heading_message, :header
      terminal.say ''
    end
  end

  def default_heading_message
    message = "❯ #{environment.current_branch} => #{onto} | " +
      "#{terminal.capture(:count_commits, onto: onto)} commits, " +
      "#{terminal.capture(:count_files, onto: onto)} files"
    unless terminal.file_filter.nil? || terminal.file_filter.empty?
      message += " (#{terminal.file_filter})"
    end
    message
  end

  def handle_keypress key
    case Command.for_key(key)
    when :begin_rebase
      terminal.call :begin_rebase, onto: onto
    when :show_diff
      show_diff
    when :sum_diff
      sum_diff
    when :filter_files
      filter_files
    when :quit
      exit
    end
  end

  def handle_keypress_mid_rebase key
    case Command.for_key(key)
    when :abort_rebase
      terminal.call :abort_rebase
    when :continue_rebase
      terminal.call :continue_rebase
    when :show_diff
      show_diff
    when :sum_diff
      sum_diff
    when :quit
      exit
    end
  end

  def show_diff
    sha = terminal.ask 'Enter a SHA', autocomplete_strategy: [:sha, { onto: onto }]
    terminal.clear
    terminal.call :show, sha: sha
    terminal.prompt_to_continue
  rescue Interrupt
  end

  def sum_diff
    start_sha = terminal.ask 'Enter the start SHA', autocomplete_strategy: [:sha, { onto: onto }]
    end_sha = terminal.ask 'Enter the end SHA', autocomplete_strategy: [:sha, { onto: onto }]
    terminal.clear
    terminal.call :sum_diff, start_sha: start_sha, end_sha: end_sha
    terminal.prompt_to_continue
  rescue Interrupt
  end

  def filter_files
    filter = terminal.ask 'Enter a filter pattern', autocomplete_strategy: [:file, {
      prefix: terminal.capture(:get_prefix),
      onto: onto
    }]
    terminal.file_filter = filter
  rescue Interrupt
  end
end