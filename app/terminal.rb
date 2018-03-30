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
    sha: -> (variables, s) {
      `git rev-list #{variables[:onto]}...`
        .split(/\n/)
        .grep(/^#{s}/)
    },
    file: ->(variables, s) {
      `git diff --name-only --relative=#{variables[:prefix]} #{variables[:onto]}...`
        .split(/\n/)
        .grep(/#{s}/)
    }
  }

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
    format(command, values)
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