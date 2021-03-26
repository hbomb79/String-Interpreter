class CommandError < StandardError
  def initialize(msg = "Unknown command error")
    super msg
  end
end