require_relative "../test_helper"

class DaemonTest < TestCase
  let(:daemon) { ApplicationDaemon::Base.new }

  after { daemon.handlers.clear }

  it "runs on every tick" do
    ApplicationDaemon::Base.every :tick do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 1, daemon.handlers[0].times_ran
  end

  it "runs every quarter second" do
    ApplicationDaemon::Base.every 0.25 do; end
    daemon.run(max_ticks: 4)
    assert_equal 2, daemon.handlers[0].times_ran
  end

  it "does not run on first tick if at_start is false" do
    ApplicationDaemon::Base.every :tick, at_start: false do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 0, daemon.handlers[0].times_ran

    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 1, daemon.handlers[0].times_ran
  end

  it "can only run max times" do
    ApplicationDaemon::Base.every :tick, max: 2 do; end
    daemon.run(max_ticks: 1, no_sleep: true)
    daemon.run(max_ticks: 1, no_sleep: true)
    daemon.run(max_ticks: 1, no_sleep: true)
    assert_equal 2, daemon.handlers[0].times_ran
  end
end
