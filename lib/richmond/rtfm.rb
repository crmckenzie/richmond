require 'find'
require 'ostruct'

module Richmond

  class RTFM

    attr_accessor :record_pattern, :end_record_pattern, :output_file_pattern

    include Richmond::Logging

    def initialize 
      @record_pattern =/^\=begin.*(output-file:\s+.*|append)/i 
      @output_file_pattern = /output-file:\s+.*\s*/i
      @end_record_pattern = /^\=end/i
      @mode = :paused
    end 

    def parse_output_file(line)
      match = line.match output_file_pattern
      smatch = match
        .to_s
        .gsub(/output-file:/, '')
        .strip

      File.expand_path smatch
    end

    def scan(dir)
      logger.info "beginning scan"
      files = Find.find(dir).to_a.reject!{|f| File.directory? f }
      result = scan_files files
      logger.info "scan finished"
      result
    end

    def scan_files(files)
      @result = ScanResult.new

      files.each do |file|
        dir = File.dirname file
        @input_filename = File.expand_path file
        @output_filename = default_output_filename dir
        
        lines = File.readlines file
        lines.each do |line|
          line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
          end_recording! line if end_recording? line
          record! line if recording?
          begin_recording! line if begin_recording? line
        end
      end

      @result
    end

    def emit(input)
      logger.info "begin emitting files"
      input.each_pair do |filename, lines|
        assert_directory_exists filename
        logger.info "writing #{filename}"
        File.open(filename, 'w') do |file|
          lines.each {|line| file.write line }
        end
      end
      logger.info "finished emitting files"
      input.keys
    end
    
    def begin_recording?(line)
      return false if line.nil?
      return true if line.match record_pattern
      false
    end
    
    def end_recording?(line)
      line.match end_record_pattern
    end

    private

    def begin_recording!(line)
      @mode = :recording 
      
      if set_output_file? line
        @output_filename = parse_output_file line
      end
      logger.debug "---#{line}"
      logger.info "---begin recording into #{@output_filename} from #{@input_filename}"
    end

    def end_recording!(line)
      @mode = :paused 
      logger.info "---end recording"
    end

    def recording?
      @mode == :recording
    end

    def record! line
      @result.output[@output_filename].push line 
      @result.input[@input_filename].push line 
    end

    def set_output_file?(line)
      line.match output_file_pattern
    end

    def assert_directory_exists(filename)
      dirname = File.dirname(filename)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
    end

    def default_output_filename(dir)
      File.join(dir,'output', 'richmond.output')
    end

  end
end
