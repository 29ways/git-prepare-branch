class Command
  CTRL_C = "\u0003"
  CTRL_D = "\u0004"

  COMMAND_KEYS = {
    abort_rebase: 'a',
    begin_rebase: 'r',
    continue_rebase: 'c',
    cycle_view: 'v',
    filter_files: 'f',
    show_diff: 'd',
    show_my_changes: 'm',
    show_their_commits: 't',
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