dir = File.dirname(File.expand_path(__FILE__))
search = "#{dir}/**/*.rb"
Dir.glob(search).each {|file| require file }

require 'find'

module Richmond

  @@default_select_blocks = [
  ]

  @@default_reject_blocks = [
    lambda {|f| File.directory? f},
    lambda {|f| f.split('/').include? '.git' }
  ]

  @@select_blocks = @@default_select_blocks
  @@reject_blocks = @@default_reject_blocks

  def self.reset_filters
    @@select_blocks = @@default_select_blocks
    @@reject_blocks = @@default_reject_blocks
  end

  def self.select_filters
    @@select_blocks
  end

  def self.reject_filters
    @@reject_blocks
  end

  def self.select(&block)
    @@select_blocks.push block
  end

  def self.reject(&block)
    @@reject_blocks.push block
  end

  def self.generate(dir)
    rtfm = RTFM.new
    settings = Richmond::ScanSettings.new dir

    scan = rtfm.scan settings 
    rtfm.emit scan.output
  end

end
