# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

##
# Basic StandardError override to allow for specific rescue statements
class ExpressionError < StandardError
  def initialize(msg = "Unknown expression error")
    super msg
  end
end