# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

require 'core/debug_output'

##
# This class is used to hold the information pertaining to a language symbol/variable.
class SymbolTableEntry

  attr_reader :name, :value, :readonly

  ##
  # Initialises this instance by setting the symbol information
  def initialize(symbol_name, symbol_value, readonly: false)
    @name = symbol_name
    @value = symbol_value
    @readonly = readonly
  end

  ##
  # Attempts to set the value of this symbol; if the symbol is readonly, this will fail.
  #
  # @raise SymbolError Raised if the symbol is readonly
  def value=(value)
    raise SymbolError, "Cannot change value (#{@value}->#{value}) of symbol #{@name} as it's readonly!" if @readonly

    @value = value
  end

  ##
  # Overrides the to_s function so when this symbol is interpolated in to a string it is formatted
  # automatically.
  def to_s
    "#{@name} -> #{@value.dump} #{@readonly ? '[readonly]' : ''}"
  end
end
