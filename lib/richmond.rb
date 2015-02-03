require "richmond/version"
require 'richmond/logging'
require 'richmond/scan_result'
require 'richmond/rtfm'

module Richmond
  # Your code goes here...

  def self.generate(dir)
    rtfm = RTFM.new
    scan = rtfm.scan dir
    rtfm.emit scan.output
  end

end
