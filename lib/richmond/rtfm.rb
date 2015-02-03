require 'find'
require 'ostruct'

module Richmond

  class RTFM

    attr_accessor :record_pattern, :end_record_pattern, :output_file_pattern

    def initialize 
      @record_pattern =/^\=begin richmond/i 
      @output_file_pattern = /output-file:\s+.*\s*/i
      @end_record_pattern = /^\=end/i
    end 

    def start_recording?(line)
      line.match record_pattern
    end

    def stop_recording?(line)
      line.match end_record_pattern
    end

    def set_output_file?(line)
      line.match output_file_pattern
    end

    def parse_output_file(line)
      match = line.match output_file_pattern
      match
        .to_s
        .gsub(/output-file:/, '')
        .strip
    end

    def scan(dir)

      input = key_array_hash
      output = key_array_hash

      files = Find.find(dir).to_a.reject!{|f| File.directory? f }
      files.each do |file|
        input_filename = File.expand_path(file)
        output_filename = default_output_filename dir

        lines = File.readlines file
        mode = :paused
        lines.each do |line|
          mode = :paused if stop_recording? line
          
          if mode == :recording
            output[output_filename].push line 
            input[input_filename].push line 
          end
          
          if set_output_file? line
            output_filename = parse_output_file line
          end
          
          mode = :recording if start_recording? line
        end
      end

      results = OpenStruct.new 
      results.input = input
      results.output = output
      results
    end

    def emit(input)
      input.each_pair do |filename, lines|
        assert_directory_exists filename
        File.open(filename, 'w') do |file|
          lines.each {|line| file.write line }
        end
      end
      input.keys
    end

    private

    def assert_directory_exists(filename)
        dirname = File.dirname(filename)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end
    end

    def key_array_hash
      Hash.new {|hash, key| hash[key] = [] }
    end

    def default_output_filename(dir)
      File.join(dir,'output', 'richmond.output')
    end

  end
end
