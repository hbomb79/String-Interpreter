# frozen_string_literal: true

require 'core/symbol_table'
require 'lang/tokenizer'
require 'lang/parser'
require 'error/tokenizer_error'
require 'error/parser_error'
require 'error/command_error'
require 'core/commands'

##
# This is the main class for this language. It contains
# all main logic to do with the state of the interpreter,
# symbol table, and the input/output from/to the user.
#
class Interpreter
  include Commands

  attr_reader :symbol_table

  ##
  # TODO: Doc
  def initialize
    @is_running = false
    @parser = Parser.new self
    @tokenizer = Tokenizer.new
    @symbol_table = SymbolTable.new
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
        s = gets

        tokens = @tokenizer.process(s.rstrip)
        tokens.each do |x|
          puts x
        end

        @parser.parse_tokens tokens
      rescue TokenizerError, ParserError, CommandError => e
        puts e.message
      rescue StandardError => e
        puts "\nWhile parsing this command, this interpreter encountered a fatal error!\nError message:\n#{e.message}\n\nStacktrace:"
        print "#{e.backtrace.join("\n")}\n\n"
      end
    end
  end
end