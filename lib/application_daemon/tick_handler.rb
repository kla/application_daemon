module ApplicationDaemon
  class TickHandler
    attr_reader :every
    attr_reader :at_start
    attr_reader :last_ran
    attr_reader :times_ran
    attr_reader :max
    attr_reader :proc
    attr_accessor :daemon

    def initialize(options)
      @every      = options[:seconds] != :tick ? options[:seconds] : nil
      @at_start   = options.fetch(:at_start, true)
      @max        = options[:max]
      @proc       = options[:proc]
      @last_ran   = nil
      @times_ran  = 0
      @daemon     = nil
    end

    def run(ticks)
      daemon.instance_exec(&proc)
    rescue => e
      daemon.on_error(e)
    ensure
      @last_ran = Time.now
      @times_ran += 1
    end

    def run?(ticks)
      return false if !at_start && ticks == 0
      return false if max && times_ran >= max
      return true unless every # always run if `every` is not set
      return true if (!last_ran && at_start) || seconds_since_last_ran >= every
      return false
    end

    def seconds_since_last_ran
      Time.now - (last_ran || daemon.started_at)
    end
  end
end
