class ExpressionError < StandardError
  def initialize(msg = "Unknown expression error")
    super msg
  end
end