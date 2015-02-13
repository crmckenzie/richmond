require "richmond/version"
require 'richmond/logging'
require 'richmond/scan_result'
require 'richmond/rtfm'
require 'find'

module Richmond

  @@find_files_in_dir = lambda do |dir|
    files = Find.find(dir).to_a
    files.reject! {|f| File.directory? f}
    files.reject! {|f| f.split('/').include? '.git' }
    files
  end

  def self.filter(&block)
    @@find_files_in_dir = block
  end

  def self.find_files_in_dir(dir)
    @@find_files_in_dir.call dir
  end

  def self.generate(dir)
    rtfm = RTFM.new
    scan = rtfm.scan dir
    rtfm.emit scan.output
  end

end
