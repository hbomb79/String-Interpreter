# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

require 'error/expression_error'
require 'core/debug_output'

##
# The parser class is responsible for accepting a stream of tokens, and confirming that they're
# in the correct order - if they are then the associated command/expression is executed.
class Parser
  include DebugOutput

  ##
  # Initialises the parser instance with sane defaults
  def initialize(interpreter)
    @app = interpreter
    @state = :ready
    @state_arg = nil
  end

  ##
  # The root of the parser, iteratively attempts to parse the meaning of the next token
  def parse_tokens(tokens)
    debug 'Starting parse of tokens received..'
    if @state != :ready
      raise_parser_error "Attempting to start parser while already running/not in ready state (state found #{@state})"
    end

    @tokens = tokens
    @token_index = 0
    @state = :root

    # Continue parse loop until method returns false
    loop do
      begin
        res = parse
        break unless res

        step_forward
      rescue StandardError => e
        @state = :ready
        raise e
      end
    end

    debug 'Parsing complete'
    @state = :ready
  end

  protected

  ##
  # Depending on the state of the parser (as in, are we inside or outside of a command), executes
  # a method that will attempt to figure out what this token means
  def parse
    case @state
    when :root
      return false unless parse_root_state
    when :command
      parse_command_state
    else
      raise_parser_error 'Unknown parser state'
    end

    true
  end

  ##
  # Returns the token currently being parsed
  def current_token
    @tokens[@token_index]
  end

  ##
  # Looks ahead by 'amount' in the token stack and returns that token
  def peek_token(amount = 1)
    index = @token_index + amount
    @tokens[index]
  end

  ##
  # Same as peek token, however rather than 'peeking', the token stack is
  # ~advanced~ to the position provided
  def step_forward(amount = 1)
    @token_index += amount
    current_token
  end

  ##
  # Parses the current token as if we're at the root state of the expression. Essentially always expects a keyword.
  def parse_root_state
    return false if current_token.nil?

    unless current_token.type == :keyword
      raise_parser_error "Unexpected token #{current_token.type} (#{current_token.value}) found. Expected keyword"
    end

    @state = :command
    @state_arg = current_token.value.to_sym

    true
  end

  ##
  # Parses a command during the command state of the parser. Depending on the state_arg (ie: the command we're
  # trying to resolve), a different configuration of tokens will be expected.
  def parse_command_state
    case @state_arg
    when :append
      name_token = expect_token :name

      @app.perform_append(name_token.value, parse_expression)
    when :list
      expect_token :terminator

      @app.perform_list
    when :exit
      expect_token :terminator

      @app.perform_exit
    when :print
      @app.perform_print parse_expression
    when :printlength
      @app.perform_printlength parse_expression
    when :printwords
      @app.perform_printwords parse_expression
    when :printwordcount
      @app.perform_printwordcount parse_expression
    when :set
      name_token = expect_token :name

      @app.perform_set(name_token.value, parse_expression)
    when :reverse
      name_token = expect_token :name

      @app.perform_reverse name_token.value
    else
      raise_parser_error "Unexpected keyword #{current_token.value}... this shouldn't happen. Please report bug."
    end

    debug "Command for #{@state_arg} completed. Resetting parser state."
    @state = :root
    @state_arg = nil
  end

  ##
  # A helper method used when we 'expect' the presence of a certain type(s) of token. The token_types param can be
  # a single type (:name), or an array of types that are acceptable (%i[name string]).
  #
  # The offset (def. 0) will be passed to peek_token when checking the token. As the default is zero, it means the
  # current token will be tested.
  #
  # If consume is true then after a successful match, the token stack will be advanced by 1 + offset.
  def expect_token(token_types, offset = 0, consume: true)
    print_token_stack

    debug "Asserting that token at offset #{offset} must be of type #{token_types} - consume? #{consume}"

    if token_types.instance_of? Array
      token_types.each do |t|
        next unless test_token(t, offset)

        tk = peek_token offset
        step_forward(1 + offset) if consume

        return tk
      end
    elsif test_token token_types, offset
      tk = peek_token offset
      step_forward(1 + offset) if consume

      return tk
    end

    pk_tk = peek_token offset
    raise_parser_error "Unexpected #{pk_tk.nil? ? 'END OF INPUT' : "#{pk_tk.type} token (#{pk_tk.value})"}, expected #{token_types} token.."
  end

  ##
  # Returns true if the current token (or otherwise specified by offset)
  # is the type provided. False if no token, or incorrect type.
  def test_token(token_type, offset = 0)
    debug "Testing for #{token_type} with offset #{offset}", :verbose

    peeked = peek_token(offset)
    !peeked.nil? && peeked.type == token_type
  end

  ##
  # Searches through the token stack in order to resolve an expression. For instance, if we're parsing the set
  # command then that command expects an expression following the name token specifying the symbol to store
  # the expression in.
  def parse_expression
    expr = []
    loop do
      raise ExpressionError, 'Expression definition incomplete.. more terms expected' unless current_token

      name = expect_token %i[name string]
      expr.append name

      debug "Expression identifier found as #{name} - appending to expr stack"

      if current_token.nil?
        raise ExpressionError, "Expected terminator (;) or operator (+) following #{name} in expression."
      elsif !(current_token.type == :operator || current_token.type == :terminator)
        raise ExpressionError, "Unexpected #{current_token} inside expression; expected terminator (;) or operator (+)"
      elsif current_token.type == :terminator
        break
      end

      step_forward
    end

    expr
  rescue ExpressionError => e
    raise_parser_error "Failed to parse expression: #{e.message}" unless @state_arg
    raise_parser_error "Expression error for #{@state_arg} command: #{e.message}"
  end

  private

  ##
  # A debug function used to print out the current token stack, and the parsers position inside of it.
  def print_token_stack
    debug 'Printing token stack:', :verbose
    @tokens.each_with_index do |tk, index|
      debug "#{index}: #{tk} #{index == @token_index ? '<- Current' : ''}", :verbose
    end
  end

  ##
  # Throws a parser exception to the interpreter
  def raise_parser_error(msg = 'Unknown')
    print_token_stack

    err = "
Parser Exception!
-----------------
State: #{@state}
Command State: #{@state_arg || 'None'}
-----------------

While attempting to parse tokenized input, we encountered the following error:
** #{msg} **"
    raise ParserError, err
  end
end
