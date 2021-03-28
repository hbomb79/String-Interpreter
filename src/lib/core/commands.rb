# frozen_string_literal: true
#
# Felton, Harry, 18032692, Assignment 1, 159.341

require 'error/command_error'
require 'error/symbol_error'
require 'core/debug_output'

##
# This module contains all the commands that the user may
# execute via the interpreters input.
#
# All commands listed here can be called from the Parser after
# it's validated that the command provided is valid from the user.
#
# This module relies on '@symbol_table' instance variable being available,
# and pointing to a SymbolTable instance -- this instance should be
# stable and made available to all components of the project to ensure
# one standardised symbol table.
module Commands
  include DebugOutput

  ##
  # Appends the expression provided by the user to the end of
  # the target symbol provided.
  #
  # @raise CommandError Raised if the target symbol, or any symbols within the expression don't exist
  def perform_append(target_symbol, expression_stack)
    unless @symbol_table.symbol? target_symbol
      raise CommandError, "Cannot append to #{target_symbol} as it doesn't exist"
    end

    sym = @symbol_table.retrieve_symbol target_symbol
    value = sym.value + (resolve_expression_stack expression_stack)

    @symbol_table.store_symbol target_symbol, value
  rescue SymbolError => e
    raise CommandError, "Command cannot be executed - #{e.message}"
  end

  ##
  # Lists all the symbols present inside the symbol table
  def perform_list
    puts 'Symbol table (special chars escaped):'
    @symbol_table.symbols.each do |sym|
      puts "#{sym.name} -> #{sym.value.dump} #{sym.readonly ? '[readonly]' : ''}"
    end
  end

  ##
  # Exits the interpreter
  def perform_exit
    close
  end

  ##
  # Resolves the expression provided and prints the result
  #
  # @raise CommandError if the expression provided references a symbol that doesn't exist
  def perform_print(expression_stack)
    expr = resolve_expression_stack expression_stack
    puts expr
  end

  ##
  # Resolves the expression provided and prints the length of the result
  #
  # @raise CommandError if the expression provided references a symbol that doesn't exist
  def perform_printlength(expression_stack)
    expr = resolve_expression_stack expression_stack
    puts expr.length
  end

  ##
  # Resolves the expression provided and prints the individual words provided in the result
  #
  # @raise CommandError if the expression provided references a symbol that doesn't exist
  def perform_printwords(expression_stack)
    expr = resolve_expression_stack expression_stack
    matches = expr.scan /[\w.]+/

    puts 'Expression provided following words:'
    puts matches.join "\n"
  end

  ##
  # Resolves the expression provided and prints amount of words found inside the result
  #
  # @raise CommandError if the expression provided references a symbol that doesn't exist
  def perform_printwordcount(expression_stack)
    expr = resolve_expression_stack expression_stack
    matches = expr.scan /[\w.]+/

    puts "Expression provided n=#{matches.length} words:"
  end

  ##
  # Sets the symbol referenced by the target_symbol, to the result of the expression provided
  #
  # @raise CommandError if the target symbol, or expression, reference a symbol that doesn't exist
  def perform_set(target_symbol, expression_stack)
    expr = resolve_expression_stack expression_stack
    @symbol_table.store_symbol target_symbol, expr
  end

  ##
  # Sets the symbol referenced by the target_symbol, to the reversed form of itself (The cat -> cat The)
  #
  # @raise CommandError if the target symbol doesn't exist
  def perform_reverse(target_symbol)
    unless @symbol_table.symbol? target_symbol
      raise CommandError, "Cannot reverse contents of #{target_symbol} as it doesn't exist"
    end

    sym = @symbol_table.retrieve_symbol target_symbol

    matches = sym.value.scan /(\w+|\.+)(\s*)/

    sym.value = ''
    matches.reverse_each do |i|
      sym.value += "#{i[1]}#{i[0]}"
    end
  end

  private

  ##
  # Resolves the expression provided by iterating over all elements inside the expr stack, and appending
  # the value of each (from symbol table) to the rolling output.
  #
  # @raise CommandError Raised if the expression contains a reference to a symbol that is not found
  def resolve_expression_stack(expression_stack)
    val = ''
    expression_stack.each do |expr_token|
      case expr_token.type
      when :string
        val += expr_token.value
      when :name
        expr_symbol = expr_token.value
        unless @symbol_table.symbol? expr_symbol
          raise CommandError,
                "Cannot retrieve value of #{expr_symbol} symbol referenced inside the expression as it doesn't exist"
        end

        val += (@symbol_table.retrieve_symbol expr_symbol).value
      else
        raise CommandError, "Unexpected #{expr_token} inside expression stack!"
      end
    end

    val
  end
end
