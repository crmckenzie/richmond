module Richmond
  class ScanSettings
    attr_reader :dir

    def initialize(dir)
      @dir = File.expand_path dir
      richmond_file = File.join(@dir, '.richmond')

      Kernel.load richmond_file if File.exists? richmond_file
    end

    def file_selectors=(value)
      @file_selectors = value
    end

    def file_selectors
      @file_selectors
    end

    def file_rejectors=(value)
      @file_rejectors = value
    end

    def file_rejectors
      @file_rejectors
    end

    def files
      
      files = Find.find(dir).to_a
      Richmond.select_filters.each do |block|
        files.select!(&block)
      end
      Richmond.reject_filters.each do |block|
        files.reject!(&block)
      end
      files
    end

  end
end
