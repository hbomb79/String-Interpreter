# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

require 'error/token_error'
require 'error/tokenizer_error'
require 'lang/token'
require 'core/debug_output'

##
# The tokenizer class exposes the various tokens that may exist for this
# program to be valid and performs processing on input strings provided.
#
# The processing sees that the input string is split in to 'tokens' (see lang/token.rb)
class Tokenizer
  include DebugOutput

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

  attr_reader :partial_string, :state

  def initialize
    reset_state
  end

  ##
  # Begins tokenizing the stream by iteratively calling tokenize until
  # no further input remains to be processed.
  def process(input_stream)
    debug 'Beginning tokenization of input'

    @stream = input_stream
    @stream_char = 1

    @output = [] if @state == :root

    until @stream.strip.empty?
      tk = tokenize
      @output.append(tk) if tk.instance_of? Token
    end

    @output
  end

  protected

  ##
  # Called iteratively by `process` until the stream is found to be empty;
  def tokenize
    return consume_string if @state == :string

    trim_stream

    # Check if we're dealing with a keyword!
    return create_token(:keyword, consume_pattern(KEYWORD_DEF)) unless @stream.match(KEYWORD_DEF).nil?

    # Now we must check to see what else we could be finding. Remember whatever we
    # encounter here is the *start* of whatever token it is; a " character here means
    # the start of a string..
    if @stream[0].match STRING_START_DEF
      @state = :string
      @partial_string['delimiter'] = @stream[0]
      consume

      return nil
    end

    return create_token(:terminator, consume) if @stream[0] == ';'
    return create_token(:operator, consume) if @stream[0] == '+'

    return create_token(:name, consume_pattern(NAME_DEF)) unless @stream.match(NAME_DEF).nil?

    raise_tokenizer_error "Illegal character '#{@stream[0]}' - unable to form a token with this character!"
  end

  private

  def reset_state
    @state = :root
    @partial_string = {
      'delimiter' => '',
      'escape_next' => false,
      'built' => ''
    }
  end

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
    debug "Creating token type #{token_type} -> #{token_value}"
    Token.new(token_type, token_value)
  rescue TokenError => e
    raise_tokenizer_error e.message
  end

  ##
  # Consumes characters from the input stream; defaults to one character.
  def consume(amount = 1)
    consumed = @stream[0..(amount - 1)]
    @stream = @stream[amount..@stream.length]
    debug "Consuming n=#{amount} chars (#{consumed})", :verbose

    consumed
  end

  ##
  # Consumes characters matching the pattern/regexp provided, and consuming
  # the amount of characters matched by this pattern
  def consume_pattern(pattern)
    m = @stream.match pattern
    return if m.nil?

    debug "Consuming n=#{m.end(0)} chars after matching #{m[0]} from #{@stream}...", :verbose
    consume m.end(0)
    m[0]
  end

  ##
  # Takes the input stream for this tokenizer and attempts to
  # tokenize a string (that is, content between two delimiting symbols). Quotes inside of
  # the string can be escaped with a backslash.
  def consume_string()
    delimiter = @partial_string['delimiter']
    escape_next = @partial_string['escape_next']
    built = @partial_string['built']
    success = false

    debug "Attempting to consume string (with delim: #{delimiter})"
    loop do
      first = @stream[0]
      break unless first

      debug "Iter for char '#{first}', escaping this char? #{escape_next}, delimiter '#{delimiter}' - current: #{built}",
            :verbose
      if escape_next
        built += ESCAPE_CHARS.include?(first) ? ESCAPE_CHARS[first] : first
        escape_next = false
      elsif first == '\\'
        escape_next = true
      elsif first == delimiter
        consume
        success = true

        break
      else
        built += first
      end

      consume
    end

    debug "String consumption success?: #{success}"
    if success
      reset_state
      create_token(:string, built)
    else
      @partial_string['escape_next'] = escape_next
      @partial_string['built'] = built
    end
  end

  def raise_tokenizer_error(msg = nil)
    raise TokenizerError.new(msg)
  end
end
