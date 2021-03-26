# frozen_string_literal: true

require 'error/token_error'
require 'error/tokenizer_error'
require 'lang/token'

##
# The tokenizer class exposes the various tokens that may exist for this
# program to be valid and performs processing on input strings provided.
#
# The processing sees that the input string is split in to 'tokens' (see lang/token.rb)
class Tokenizer
  ESCAPE_CHARS = {
    'a' => "\a",
    'b' => "\b",
    'f' => "\f",
    'n' => "\n",
    'r' => "\r",
    't' => "\t",
    'v' => "\v"
  }.freeze

  ##
  # This regex matches any of our keywords/commands.rb, must be followed by a word boundary (end of
  # the string, or whitespace, etc)
  KEYWORD_DEF = /^(append|list|exit|print|printlength|printwords|printwordcount|set|reverse)\b/.freeze

  ##
  # Used to detect the start of a string literal
  STRING_START_DEF = /^["']/.freeze

  ##
  # Matches a 'name' identifier by matching alpha char, followed by any combination of alphanumeric
  # chars (incl. underscore). For instance: this_is_name1 will match as a name, but 1name will not.
  NAME_DEF = /^([a-zA-Z][a-zA-z\d]*)/.freeze

  ##
  # Begins tokenizing the stream by iteratively calling tokenize until
  # no further input remains to be processed.
  def process(input_stream)
    @original_stream = input_stream
    @stream = input_stream
    @stream_char = 1
    @output = []

    @output.append(tokenize) until @stream.strip.empty?

    @output
  end

  protected

  ##
  # Called iteratively by `process` until the stream is found to be empty;
  def tokenize
    trim_stream

    # Check if we're dealing with a keyword!
    return create_token(:keyword, consume_pattern(KEYWORD_DEF)) unless @stream.match(KEYWORD_DEF).nil?

    # Now we must check to see what else we could be finding. Remember whatever we
    # encounter here is the *start* of whatever token it is; a " character here means
    # the start of a string..
    return create_token(:terminator, consume) if @stream[0] == ';'
    return create_token(:operator, consume) if @stream[0] == '+'
    return create_token(:string, consume_string(@stream[0])) if @stream[0].match STRING_START_DEF
    return create_token(:name, consume_pattern(NAME_DEF)) unless @stream.match(NAME_DEF).nil?

    raise_tokenizer_error "Illegal character '#{@stream[0]}' - unable to form a token with this character!"
  end

  def raise_tokenizer_error(msg = nil)
    raise TokenizerError.new(@original_stream, @stream, msg)
  end

  private

  ##
  # Trims the stream by removing leading whitespace, and advancing
  # the character stream counter to compensate.
  def trim_stream
    trimmed = @stream.lstrip

    return if trimmed.nil?

    @stream_char += (@stream.length - trimmed.length)
    @stream = trimmed
  end

  ##
  # Helper method that creates a token with the provided type and value, and
  # also consumes the content of the token from the input stream.
  def create_token(token_type, token_value)
    Token.new(token_type, token_value)
  rescue TokenError => e
    raise_tokenizer_error e.message
  end

  ##
  # Consumes characters from the input stream; defaults to one character.
  def consume(amount = 1)
    consumed = @stream[0..(amount - 1)]
    @stream = @stream[amount..@stream.length]

    consumed
  end

  ##
  # Consumes characters matching the pattern/regexp provided, and consuming
  # the amount of characters matched by this pattern
  def consume_pattern(pattern)
    m = @stream.match pattern
    return if m.nil?

    puts "Consuming n=#{m.end(0)} chars after matching #{m[0]} from #{@stream}..."
    consume m.end(0)
    puts @stream
    m[0]
  end

  ##
  # Takes the input stream for this tokenizer and attempts to
  # tokenize a string (that is, content between two delimiting symbols). Quotes inside of
  # the string can be escaped with a backslash.
  def consume_string(delimiter = '"')
    escape_next = false
    success = false
    str = ''

    loop do
      consume
      first = @stream[0]

      puts("Iter for char '#{first}', escaping this char? #{escape_next}, delimiter '#{delimiter}' - current: #{str}")
      if escape_next
        str += ESCAPE_CHARS.include?(first) ? ESCAPE_CHARS[first] : first
        escape_next = false
      elsif first == '\\'
        escape_next = true
      elsif first == delimiter
        consume
        success = true

        break
      else
        str += first
      end
    end

    puts "success: #{success}"
    unless success
      raise_tokenizer_error "Failed to tokenize string, delimited by #{delimiter}... end of string was never found!"
    end

    str
  end
end
