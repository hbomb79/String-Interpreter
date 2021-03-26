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
      parse_root_state
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

  private

  ##
  # TODO: Doc
  def parse_root_state
    unless current_token.type == :keyword
      raise_parser_error "Unexpected token #{current_token.type} (#{current_token.value}) found. Expected keyword"
    end

    @state = :command
    @state_arg = current_token.value.to_sym
  end

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
  end

  def expect_token(token_type, offset = 0, consume = true)
    print_token_stack
    puts "Testing for #{token_type} with offset #{offset}"

    peeked = peek_token(offset)
    raise_parser_error "Expected #{token_type} token, but found #{peeked.nil? ? 'END OF STATEMENT' : peeked}." unless !peeked.nil? && peeked.type == token_type

    step_forward if consume
    peeked
  end

  def print_token_stack
    puts "Token stack:"
    @tokens.each_with_index do |tk, index|
      puts "#{index}: #{tk} #{index == @token_index ? "<- Current" : ""}"
    end
  end

  def parse_expression
    expr = []
    raise ExpressionError, 'No terms found' if current_token.nil?

    loop do
      print_token_stack
      # Test we have tokens remaining
      raise ExpressionError, 'Expected more terms (NAME, OPERATOR or TERMINATOR)' if current_token.nil?

      # Each iteration consumes a block which should be of format: name [+/;]
      # If `name +` then iteration continues, searching for another name on next iter
      # If `name ;` then iteration is terminated
      name = expect_token :name
      puts "Expression NAME found as #{name}"
      expr.append name.value

      # Check token following name, must be + or ;
      puts "Expression VALUE found as #{current_token}"
      if current_token.nil?
        raise ExpressionError, "Expected terminator (;) or operator (+) token following #{name} in expression."
      elsif !(current_token.type == :operator || current_token.type == :terminator)
        raise ExpressionError, "Unexpected #{current_token} inside expression; expected terminator (;) or operator (+)"
      elsif current_token.type == :terminator
        break
      end

      step_forward
    end

    expr
  rescue ExpressionError => e
    raise_parser_error "Failed to parse expression: #{e.message}"
  end

  def raise_parser_error(msg = 'Unknown')
    raise ParserError, msg
  end
end
