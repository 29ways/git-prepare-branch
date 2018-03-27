class Logger
  def initialize(stream: $stdout)
    @stream = stream
  end

  def log message
    stream << format_message(message)
    stream.flush
  end

  private

  attr_reader :stream

  def format_message(message)
    "#{Time.now}: #{message}\n"
  end
end