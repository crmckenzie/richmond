require 'find'
require 'ostruct'

module Richmond

  class RTFM

    attr_accessor :record_pattern, :end_record_pattern, :output_file_pattern

    include Richmond::Logging

    def initialize 
      @record_pattern      =/^\=begin richmond/i
      @output_file_pattern = /output-file:\s+.*\s*/i
      @end_record_pattern  = /^\=end/i
      @mode                = :paused
    end

    def parse_output_file(line)
      line.match(output_file_pattern)
        .to_s
        .gsub(/output-file:/, '')
        .strip
    end

    def scan(dir)
      note "beginning scan"
      mark_where_the_output_file_will_be_for dir
      result = scan_files all_of_the_files_in(dir)
      note "scan finished"
      result
    end

    def scan_files(files)
      note "scanning files: default output filename=#{@output_filename}"
      @result = ScanResult.new
      files.each { |f| look_for_documentation_in f }
      @result
    end

    def emit(input)
      note "begin emitting files"
      input.each_pair { |f, l| write_these_lines_to_a_file l, f }
      note "finished emitting files"
      #input.keys
    end

    private

    def look_for_documentation_in file
      @the_name_of_the_file_being_read = File.expand_path file
      File.readlines(file).each do |line|
        begin
          stop_recording! line if stop_recording? line
          record! line if recording?
          start_recording! line if start_recording? line
        rescue
          @mode = :paused 
        end
      end
    end

    def write_these_lines_to_a_file lines, file
      assert_directory_exists file
      note "writing #{file}"
      File.open(file, 'w') { |f| lines.each { |l| f.write l } }
    end

    def all_of_the_files_in dir
      Find.find(dir).to_a.reject! { |f| File.directory? f }
    end

    def start_recording?(line)
      line.match record_pattern
    end

    def start_recording!(line)
      @mode = :recording 
      note "start recording"

      return unless set_output_file? line
      @output_filename = parse_output_file line
      note "changing output file to #{@output_filename}"
    end

    def stop_recording?(line)
      line.match end_record_pattern
    end

    def stop_recording!(line)
      @mode = :paused
      note "stop recording"
    end

    def recording?
      @mode == :recording
    end

    def record! line
      @result.output[@output_filename].push line
      @result.input[@the_name_of_the_file_being_read].push line
    end

    def set_output_file?(line)
      line.match output_file_pattern
    end

    def assert_directory_exists(filename)
      #dirname = File.dirname(filename)
      #unless File.directory?(dirname)
        #FileUtils.mkdir_p(dirname)
      #end
    end

    def default_output_filename(dir)
      File.join(dir,'output', 'richmond.output')
    end

    def mark_where_the_output_file_will_be_for(dir)
      @output_filename = default_output_filename dir
    end

  end

end
