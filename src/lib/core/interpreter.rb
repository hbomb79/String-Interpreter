# frozen_string_literal: true
#
# Felton, Harry, 18032692, Assignment 1, 159.341

require 'core/symbol_table'
require 'lang/tokenizer'
require 'lang/parser'
require 'error/tokenizer_error'
require 'error/parser_error'
require 'error/command_error'
require 'core/commands'
require 'core/debug_output'

##
# This is the main class for this language. It contains
# all main logic to do with the state of the interpreter,
# symbol table, and the input/output from/to the user.
#
class Interpreter
  include Commands
  include DebugOutput

  ##
  # The debug level for this application. Options are :off, :basic and :verbose
  DEBUG_LEVEL = :off

  ##
  # This character, once found at the end of an input string
  # will terminate the user input (and hand off this information
  # to the tokenizer/parser). It marks the end of user input for this current
  # command. For this program that is a semi-colon followed by a newline.
  INPUT_TERMINATOR = ";\n"

  attr_reader :symbol_table

  ##
  # Initialise the interpreter by configuring our debugger, and initialising our tokenizer, parser and symbol table.
  def initialize
    DebugOutput.debug_level = DEBUG_LEVEL

    @is_running = false

    @parser = Parser.new self
    @tokenizer = Tokenizer.new
    @symbol_table = SymbolTable.new

    init_constants
  end

  ##
  # Populates the symbol table with our readonly symbols
  def init_constants
    @symbol_table.store_symbol 'SPACE', ' ', readonly: true
    @symbol_table.store_symbol 'TAB', "\t", readonly: true
    @symbol_table.store_symbol 'NEWLINE', "\n", readonly: true
  end

  ##
  # Opens the interpreter by allowing user input
  def open
    @is_running = true
    run_interpreter
  end

  ##
  # Closes the interpreter
  def close
    @is_running = false
  end

  protected

  ##
  # The root of the interpreter; runs a loop while @is_running, and continually
  # requests user input from STDIN. The input is haded to the tokenizer, and the
  # resulting tokens are parsed. All predictable exceptions are rescued here.
  def run_interpreter
    while @is_running
      begin
        printf '> '
        s = gets INPUT_TERMINATOR

        tokens = @tokenizer.process(s.rstrip)
        tokens.each do |x|
          debug x
        end

        @parser.parse_tokens tokens
      rescue TokenizerError, ParserError => e
        warn "\n[#{e.class.name}] Syntax error => #{e.message}"
      rescue CommandError, SymbolError => e
        warn "\n[#{e.class.name}] Command invalid => #{e.message}"
      rescue StandardError => e
        warn "\nWhile parsing this command, this interpreter encountered a fatal error!\nError message:\n#{e.message}\n\nStacktrace:"
        warn "#{e.backtrace.join("\n")}\n\n"
      end
    end
  end
end