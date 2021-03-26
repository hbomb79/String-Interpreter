##
#
module DebugOutput
  VALID_DEBUG_LEVELS = %i[off basic verbose].freeze
  @debug_level = :off

  def debug(msg, level = :basic)
    debug_level = DebugOutput.debug_level
    return if debug_level == :off
    return if debug_level == :basic && level == :verbose

    warn "[DEBUG] [#{level.to_s.capitalize}] #{msg}"
  end

  def self.debug_level=(debug_level)
    unless VALID_DEBUG_LEVELS.include? debug_level
      raise "Cannot set debug level to #{debug_level}; only #{VALID_DEBUG_LEVELS} are valid debug levels."
    end

    @debug_level = debug_level
  end

  def self.debug_level
    @debug_level
  end
end
