require 'readline'
require 'io/console'

class Terminal
  CLEAR = 'clear'
  DEFAULT_PROMPT = ' ❯ '
  DEFAULT_WIDTH = 20
  HR_CHARACTER = '─'
  BLANK_CHARACTER = ' '
  NUM_BLANK_LINES_BEFORE_PROMPT = 3

  AUTOCOMPLETE_STRATEGIES = {
    default: -> (_, _) {},
    sha: -> (options, s) {
      `git rev-list #{options[:onto]}...`
        .split(/\n/)
        .grep(/^#{s}/)
    },
    file: ->(options, s) {
      `git diff --name-only --relative=#{options[:prefix]} #{options[:onto]}...`
        .split(/\n/)
        .grep(/#{s}/)
    }
  }

  COMMANDS = {
    abort_rebase: 'git rebase --abort',
    check_if_mid_rebase: 'if test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply)"; then echo 1; fi',
    continue_rebase: 'git rebase --continue',
    count_commits: 'git rev-list --count %{onto}...',
    count_files: 'git diff --name-only %{onto}... | wc -l',
    current_branch: 'git rev-parse --abbrev-ref HEAD',
    get_prefix: 'git rev-parse --show-prefix',
    list_commits: 'git log --oneline --decorate --reverse %{view} %{onto}.. *%{file_filter}*',
    begin_rebase: 'git rebase -i %{onto}',
    show: 'git show %{sha}',
    status: 'git status -s',
    sum_diff: 'git diff -w --find-renames --find-copies --patience %{start_sha}~...%{end_sha}'
  }

  attr_accessor :file_filter

  def initialize(out: $stdout, err: $stderr, prompt: DEFAULT_PROMPT, logger: nil, styles: nil)
    @out = out
    @err = err
    @prompt = prompt
    @logger = logger || Logger.new
    @styles = styles || Styles.new
  end

  def ask(question, autocomplete_strategy: :default)
    set_autocomplete_strategy autocomplete_strategy
    Readline.readline("#{question}#{prompt}", true).chomp.strip
  end

  def blank_lines(quantity = 1)
    quantity.times { out.puts }
  end

  def call(command, values = {})
    command = normalise_command(command, values)
    logger.log "CMD: #{command}"
    result = system command, out: out, err: err
    logger.log "OUT: #{out}"
    logger.log "ERR: #{err}"
    result
  end

  def capture(command, values = {})
    command = normalise_command(command, values)
    logger.log "CAP: #{command}"
    result = `#{command}`.chomp.strip
    logger.log "OUT: #{result}"
    result
  end

  def clear
    call CLEAR
  end

  def enable_raw
    system("stty raw -echo")
  end

  def hr
    out.puts styles.hr(HR_CHARACTER * width)
  end

  def prompt_to_continue
    blank_lines NUM_BLANK_LINES_BEFORE_PROMPT
    hr
    say styles.footer('Press any key to continue')
    wait_for_keypress {}
  end

  def reset_raw
    system("stty -raw echo")
  end

  def say(output, style = :default)
    puts styles.apply(output, style)
  end

  def wait_for_keypress
    while true do
      begin
        enable_raw
        char = STDIN.getc
        return char
      ensure
        reset_raw
      end
    end
  end

  def write_line(output, style = :default)
    puts styles.apply(make_full_width(output), style)
  end

  private

  attr_reader :out, :err, :prompt, :logger, :styles

  def normalise_command(command, values = {})
    return command if command.is_a?(String)
    format(COMMANDS[command], values)
  end

  def set_autocomplete_strategy strategy
    Readline.completion_append_character = " "
    strategy = Array(strategy)
    Readline.completion_proc = AUTOCOMPLETE_STRATEGIES[strategy[0]].curry.call(strategy[1])
  end

  def width
    begin
      IO.console.winsize[1]
    rescue NotImplementedError
      DEFAULT_WIDTH
    end
  end

  def make_full_width(text)
    text + (BLANK_CHARACTER * [width - text.length, 0].max)
  end
end