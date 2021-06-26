# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

##
# Basic StandardError override to allow for specific rescue statements
class SymbolError < StandardError
  def initialize(msg = 'Unknown symbol error')
    super msg
  end
end
