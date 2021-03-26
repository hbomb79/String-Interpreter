# frozen_string_literal: true

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

  DEBUG_LEVEL = :off

  attr_reader :symbol_table

  ##
  # TODO: Doc
  def initialize
    DebugOutput.debug_level = DEBUG_LEVEL

    @is_running = false

    @parser = Parser.new self
    @tokenizer = Tokenizer.new
    @symbol_table = SymbolTable.new

    init_constants
  end

  def init_constants
    @symbol_table.store_symbol 'SPACE', ' ', readonly: true
    @symbol_table.store_symbol 'TAB', "\t", readonly: true
    @symbol_table.store_symbol 'NEWLINE', "\n", readonly: true
  end

  ##
  # TODO: Doc
  def open
    @is_running = true
    run_interpreter
  end

  ##
  # TODO: Doc
  def close
    @is_running = false
  end

  protected

  ##
  # TODO: Doc
  def run_interpreter
    while @is_running
      begin
        printf '> '
        s = $stdin.gets

        tokens = @tokenizer.process(s.rstrip)
        tokens.each do |x|
          debug x
        end

        @parser.parse_tokens tokens
      rescue TokenizerError, ParserError => e
        warn "[#{e.class.name}] Syntax error => #{e.message}"
      rescue CommandError, SymbolError => e
        warn "[#{e.class.name}] Command invalid => #{e.message}"
      rescue StandardError => e
        warn "\nWhile parsing this command, this interpreter encountered a fatal error!\nError message:\n#{e.message}\n\nStacktrace:"
        warn "#{e.backtrace.join("\n")}\n\n"
      end
    end
  end
end