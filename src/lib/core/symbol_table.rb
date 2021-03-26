# frozen_string_literal: true

require 'core/symbol_table_entry'

##
#
class SymbolTable
  attr_reader :symbols

  def initialize
    @symbols = []
  end

  ##
  # Stores the value provided in a new symbol entry in the symbol table
  #
  # If the symbol already exists, attempts to change the value.
  #
  # @raise SymbolError Raised if the symbol being edited is readonly (only valid for pre-existing symbol)
  def store_symbol(symbol_name, symbol_value)
    sym = fetch_symbol symbol_name
    if sym
      raise SymbolError, "Symbol #{sym} cannot be modified" if sym.readonly

      sym.value = symbol_value
    else
      sym = SymbolTableEntry.new(symbol_name, symbol_value) if sym.nil?
      @symbols.append sym
    end
  end

  def retrieve_symbol(symbol_name)
    fetch_symbol symbol_name, optional: false
  end

  def symbol?(symbol_name)
    sym = fetch_symbol(symbol_name)
    !sym.nil?
  end

  protected

  def fetch_symbol(symbol_name, optional: true)
    sym_find_res = @symbols.select { |e| e.name == symbol_name }
    raise SymbolError, "Multiple #{symbol_name} symbols found inside symbol table!" if sym_find_res.length > 1

    sym = sym_find_res[0]
    raise SymbolError, "Cannot find symbol #{symbol_name}" if sym.nil? && !optional

    sym
  end
end
