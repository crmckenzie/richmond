require 'logger'

module Richmond
  module Logging

    class << self
     
      def logger
        @logger ||= Logger.new logging_target 
      end

      def logger=(value)
        @logger = value
      end

      private

      def logging_target
        @logging_target ||= $stdout 
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
