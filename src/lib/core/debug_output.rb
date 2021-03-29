# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

##
# Simple singleton module to allow the application to write debug
# information out to stderr (via warn).
module DebugOutput
  VALID_DEBUG_LEVELS = %i[off basic verbose].freeze
  @debug_level = :off

  ##
  # Write information useful for debugging out to stderr (via warn).
  # Only written if the level provided is enabled (DebugOutput.debug_level=)
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
