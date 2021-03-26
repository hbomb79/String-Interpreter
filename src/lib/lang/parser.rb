# frozen_string_literal: true

require 'error/expression_error'

##
# TODO: Doc
class Parser
  ##
  # TODO: Doc
  def initialize(interpreter)
    @app = interpreter
    @state = :ready
    @state_arg = nil
  end

  ##
  # TODO: Doc
  def parse_tokens(tokens)
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

    puts 'Parsing complete'
    @state = :ready
  end

  protected

  ##
  # TODO: Doc
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
  # TODO: Doc
  def current_token
    @tokens[@token_index]
  end

  ##
  # TODO: Doc
  def peek_token(amount = 1)
    index = @token_index + amount
    @tokens[index]
  end

  ##
  # TODO: Doc
  def step_forward(amount = 1)
    @token_index += amount
    current_token
  end

  ##
  # TODO: Doc
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
  # TODO: Doc
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
      puts "searching for set target"
      name_token = expect_token :name

      puts "performing set"
      @app.perform_set(name_token.value, parse_expression)
    when :reverse
      name_token = expect_token :name

      @app.perform_reverse name_token.value
    else
      raise_parser_error "Unexpected keyword #{current_token.value}... this shouldn't happen. Please report bug."
    end

    @state = :root
    @state_arg = nil
  end

  ##
  # TODO: Doc
  def expect_token(token_types, offset = 0, consume: true)
    print_token_stack

    if token_types.instance_of? Array
      token_types.each do |t|
        next unless test_token(t, offset)

        tk = peek_token offset
        step_forward(1 + offset) if consume

        return tk
      end

      return false
    elsif test_token token_types, offset
      tk = peek_token offset
      step_forward(1 + offset) if consume

      return tk
    end

    raise_parser_error "Unexpected #{(peek_token offset) || 'END OF INPUT'}, expected #{token_types} token.."
  end

  ##
  # Returns true if the current token (or otherwise specified by offset)
  # is the type provided. False if no token, or incorrect type.
  def test_token(token_type, offset = 0)
    puts "Testing for #{token_type} with offset #{offset}"

    peeked = peek_token(offset)
    !peeked.nil? && peeked.type == token_type
  end

  ##
  # TODO: Doc
  def parse_expression
    expr = []

    loop do
      print_token_stack
      # Test we have tokens remaining
      raise ExpressionError, 'Expression definition incomplete.. more terms expected (NAME, STRING, OPERATOR or TERMINATOR)' if current_token.nil?

      # Each iteration consumes a block which should be of format: name [+/;]
      # If `name +` then iteration continues, searching for another name on next iter
      # If `name ;` then iteration is terminated
      name = expect_token %i[name string]

      puts "Expression TARGET found as #{name}"
      expr.append name

      # Check token following name, must be + or ;
      puts "Expression FOLLOWER found as #{current_token}"
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
  # TODO: Doc
  def print_token_stack
    puts "Token stack:"
    @tokens.each_with_index do |tk, index|
      puts "#{index}: #{tk} #{index == @token_index ? "<- Current" : ""}"
    end
  end

  ##
  # TODO: Doc
  def raise_parser_error(msg = 'Unknown')
    raise ParserError, msg
  end
end
