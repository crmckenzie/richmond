require 'find'
require 'ostruct'

module Richmond
  class RTFM

    def default_output_filename(dir)
      File.join(dir,'output', 'richmond.output')
    end

    def rtfm(dir)
      
      input = Hash.new {|hash, key| hash[key] = [] }
      output = Hash.new {|hash, key| hash[key] = [] }

      files = Find.find(dir).select{|f| f.match(/.rb$/i) }
      files.each do |file|
        input_filename = File.expand_path(file)
        output_filename = default_output_filename dir

        lines = File.readlines file
        mode = :paused
        lines.each do |line|
          if line.match(/^\=begin richmond/i)
            mode = :recording

            match =  line.match(/output-file:\s+.*\s*/)
            if match
              output_filename = match
                .to_s
                .gsub(/output-file:/, '')
                .strip
            else
              output_filename = default_output_filename dir
            end
          
          elsif line.match(/^\=end/i)
            mode = :paused
          elsif mode == :recording
            scrubbed = line.gsub("\n", '')
            output[output_filename].push scrubbed 
            input[input_filename].push scrubbed 
          end
        end
      end

      results = OpenStruct.new 
      results.input = input
      results.output = output
      results
    end

    def emit(input)
      input.each_pair do |filename, lines|
        dirname = File.dirname(filename)
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dirname)
        end

        File.open(filename, 'w') do |file|
          puts "writing #{lines.size} lines to #{filename}"
          lines.each {|line| file.write "#{line}\n" }
        end
      end
      input.keys
    end
  end
end
