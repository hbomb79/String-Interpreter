class ParserError < StandardError
  def initialize(error = nil)
    super error
  end
end