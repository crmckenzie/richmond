require 'find'
require 'ostruct'

module Richmond

  class RTFM

    attr_accessor :record_pattern, :end_record_pattern, :output_file_pattern

    include Richmond::Logging

    def initialize 
      @record_pattern =/^\=begin richmond/i 
      @output_file_pattern = /output-file:\s+.*\s*/i
      @end_record_pattern = /^\=end/i
      @mode = :paused
    end 

    def parse_output_file(line)
      line.match(output_file_pattern)
        .to_s
        .gsub(/output-file:/, '')
        .strip
    end

    def scan(dir)
      logger.info "beginning scan"
      files = Find.find(dir).to_a.reject!{|f| File.directory? f }
      @output_filename = default_output_filename dir
      result = scan_files files
      logger.info "scan finished"
      result
    end

    def scan_files(files)
      logger.info "scanning files: default output filename=#{@output_filename}"
      @result = ScanResult.new

      files.each do |file|
        @input_filename = File.expand_path file
        lines = File.readlines file
        lines.each do |line|
          begin
            stop_recording! line if stop_recording? line
            record! line if recording?
            start_recording! line if start_recording? line
          rescue
          end
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

    private
    
    def start_recording?(line)
      line.match record_pattern
    end

    def start_recording!(line)
      @mode = :recording 
      logger.info "start recording"
      
      if set_output_file? line
        @output_filename = parse_output_file line
        logger.info "changing output file to #{@output_filename}"
      end
    end

    def stop_recording?(line)
      line.match end_record_pattern
    end

    def stop_recording!(line)
      @mode = :paused 
      logger.info "stop recording"
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
