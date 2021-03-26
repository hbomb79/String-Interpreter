# frozen_string_literal: true

require 'core/symbol'

##
#
class SymbolTable
  attr_reader :symbols

  def initialize
    @symbols = []
  end

  def store_symbol(symbol_name, symbol_value)
    # TODO: ..
  end

  def retrieve_symbol(symbol_name)
    # TODO: ..
  end

  def has_symbol(symbol_name)
    # TODO: ..
  end
end