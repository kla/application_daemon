require_relative "../test_helper"

class DaemonTest < TestCase
  class TestLogger
    attr_reader :message

    def error(message)
      @message = message
    end
  end

  class Daemon < ApplicationDaemon::Base
    def on_error(exception)
      @errored = true
      super
    end
  end

  let(:logger) { TestLogger.new }
  let(:daemon) { Daemon.new(logger: logger) }

  after { daemon.handlers&.clear }

  it "runs on every tick" do
    Daemon.every :tick do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 1, daemon.handlers[0].times_ran
  end

  it "runs every quarter second" do
    Daemon.every 0.25 do; end
    daemon.run(max_ticks: 4)
    assert_equal 2, daemon.handlers[0].times_ran
  end

  it "does not run on first tick if at_start is false" do
    Daemon.every :tick, at_start: false do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 0, daemon.handlers[0].times_ran

    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 1, daemon.handlers[0].times_ran
  end

  it "does not run at_start if time specified" do
    Daemon.every 1, at_start: false do; end
    daemon.run(max_ticks: 11) # 0.1 tick
    assert_equal 1, daemon.handlers[0].times_ran
  end

  it "can only run max times" do
    Daemon.every :tick, max: 2 do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    daemon.run(max_ticks: 1, no_sleep: true)
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 2, daemon.handlers[0].times_ran
  end

  it "logs errors" do
    Daemon.every :tick do
      raise "something"
    end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_match "something", logger.message
  end

  it "calls on_error if an error occurs" do
    Daemon.every :tick do
      raise "something"
    end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert daemon.instance_variable_get(:@errored)
  end
end
