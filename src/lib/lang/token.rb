# frozen_string_literal: true

require 'error/token_error'

##
# TODO
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
