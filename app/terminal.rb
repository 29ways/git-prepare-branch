require 'readline'

class Terminal
  CLEAR = 'clear'
  DEFAULT_PROMPT = '❯ '
  DEFAULT_WIDTH = 20
  HR_CHARACTER = '─'
  NUM_BLANK_LINES_BEFORE_PROMPT = 3

  AUTOCOMPLETE_STRATEGIES = {
    default: -> (_, _) {},
    sha: -> (options, s) {
      `git rev-list #{options[:onto]}...`
        .split("\n")
        .grep(/^#{s}/)
    }
  }

  COMMANDS = {
    current_branch: 'git rev-parse --abbrev-ref HEAD',
    list_commits: 'git log --oneline --decorate --reverse %{onto}...',
    begin_rebase: 'git rebase -i %{onto}',
    show: 'git show %{sha}'
  }

  def initialize(out: $stdout, err: $stderr, prompt: DEFAULT_PROMPT, logger: nil)
    @out = out
    @err = err
    @prompt = prompt
    @logger = logger || Logger.new
  end

  def ask(question, autocomplete_strategy: :default)
    set_autocomplete_strategy autocomplete_strategy
    Readline.readline "#{question}#{prompt}", true
  end

  def blank_lines(quantity = 1)
    quantity.times { out.puts }
  end

  def call(command, values = {})
    command = normalise_command(command, values)
    logger.log "#{command}"
    system command, out: out, err: err
  end

  def capture(command, values = {})
    command = normalise_command(command, values)
    `#{command}`.chomp
  end

  def clear
    call CLEAR
  end

  def hr
    out.puts HR_CHARACTER * width
  end

  def prompt_to_continue
    blank_lines NUM_BLANK_LINES_BEFORE_PROMPT
    hr
    say 'Press enter to continue'
    STDIN.read(1)
  end

  def say(output)
    puts output
  end

  private

  attr_reader :out, :err, :prompt, :logger

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
      Readline.get_screen_size[1]
    rescue NotImplementedError
      DEFAULT_WIDTH
    end
  end
end