require_relative "tick_handler"

module ApplicationDaemon
  class Base
    DEFAULT_SLEEP = 0.1 # seconds

    attr_reader :started_at, :options

    def self.every(seconds, options={}, &block)
      (@handlers ||= [ ]) << TickHandler.new(options.merge(seconds: seconds, proc: block))
    end

    def initialize(options={})
      @started_at = Time.now
      @sleep_time = options.fetch(:sleep_time, DEFAULT_SLEEP)
      @ticks = 0
      @logger = options[:logger] || (Gem.loaded_specs.has_key?('rails') ? Rails.logger : nil)
      @options = options.reject { |k| k == :sleep_time || k == :logger }
    end

    def handlers
      self.class.instance_variable_get(:@handlers)
    end

    def run(options={})
      raise "No handlers defined!" unless handlers

      loop do
        next unless handlers

        handlers.each do |handler|
          handler.daemon = self unless handler.daemon
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

    def elapsed
      Time.now - @started_at
    end
  end
end
