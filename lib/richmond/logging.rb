require 'logger'

module Richmond
  module Logging

    class << self
     
      def logger
        @logger ||= Logger.new $stdout 
      end

      def logger=(value)
        @logger = value
      end

    end

    # Addition
    def self.included(base)
      class << base
        def logger
          Logging.logger
        end
      end
    end

    def logger
      Logging.logger
    end
  end
end
