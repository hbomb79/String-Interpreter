# frozen_string_literal: true

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