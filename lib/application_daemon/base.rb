require_relative "tick_handler"

module ApplicationDaemon
  class Base
    DEFAULT_SLEEP = 0.1 # seconds

    def self.every(seconds, options={}, &block)
      (@handlers ||= [ ]) << TickHandler.new(options.merge(seconds: seconds, proc: block))
    end

    def initialize(sleep_time: DEFAULT_SLEEP, logger: nil)
      @sleep_time = sleep_time || DEFAULT_SLEEP
      @ticks = 0
      @logger = !logger && Object.const_defined?("::Rails") ? ::Rails.logger : logger
    end

    def handlers
      self.class.instance_variable_get(:@handlers)
    end

    def run(options={})
      raise "No handlers defined!" unless handlers

      loop do
        next unless handlers

        handlers.each do |handler|
          next unless handler.run?(@ticks)
          handler.run(@ticks)
        end
      rescue => e
        message = "#{e.message}\n#{e.backtrace.join("\n")}"
        @logger ? @logger.error(message) : puts(message)
      ensure
        sleep(@sleep_time) unless options[:no_sleep]
        @ticks += 1
        return if options[:max_ticks] && @ticks >= options[:max_ticks]
      end
    end
  end
end
