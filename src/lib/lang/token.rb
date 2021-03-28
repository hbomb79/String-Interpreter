# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

require 'error/token_error'

##
# A simple class to hold information about our tokens
class Token
  VALID_TOKEN_TYPES = %i[keyword string name operator terminator].freeze

  attr_reader :type, :value

  def initialize(token_type, token_value)
    raise TokenError, "Unknown token type '#{token_type}' provided..." unless VALID_TOKEN_TYPES.include?(token_type)

    @type = token_type
    @value = token_value
  end

  def to_s
    "Token [type: #{@type}, value: #{@value}]"
  end
end
