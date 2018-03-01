class Command
  CTRL_C = "\u0003"
  CTRL_D = "\u0004"

  COMMAND_KEYS = {
    begin_rebase: 'r',
    show_diff: 'd',
    sum_diff: 's',
    quit: ['q', CTRL_C, CTRL_D]
  }

  def self.for_key(key)
    COMMAND_KEYS
      .select { |k, v| Array(v).include?(key) }
      .keys
      .first
  end
end