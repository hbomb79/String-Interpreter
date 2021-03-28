# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

##
# Basic StandardError override to allow for specific rescue statements
class TokenizerError < StandardError
  def initialize(original_stream, stream_partial, error = 'Unknown error')
    err = "
Tokenizer Exception!
--------------------
While attempting to tokenize input, we encountered the following error:
** #{error} **"
    super err
  end
end
