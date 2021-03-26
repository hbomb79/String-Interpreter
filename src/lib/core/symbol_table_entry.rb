# frozen_string_literal: true

##
# TODO
class SymbolTableEntry

  attr_reader :name, :value, :readonly

  ##
  # TODO: Doc
  def initialize(symbol_name, symbol_value, readonly: false)
    @name = symbol_name
    @value = symbol_value
    @readonly = readonly
  end

  ##
  #
  def value=(value)
    raise "Cannot change value (#{@value}->#{value}) of symbol #{@name} as it's readonly!" if @readonly

    @value = value
  end

  def to_s
    "Symbol {name=#{@name}, val=#{@value}, readonly?=#{@readonly}}"
  end
end
