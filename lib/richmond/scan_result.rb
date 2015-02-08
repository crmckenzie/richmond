class ScanResult
  attr_accessor :input, :output

  def initialize
    @input  = key_array_hash 
    @output = key_array_hash 
  end

  private

  def key_array_hash
    Hash.new { |hash, key| hash[key] = [] }
  end

end
