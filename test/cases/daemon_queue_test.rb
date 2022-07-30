require "test_helper"

class DaemonQueueTest < TestCase
  class DaemonWithQueue < ::ApplicationDaemon::Base
    include ::ApplicationDaemon::Queue
  end

  let(:daemon) { DaemonWithQueue.new }

  it "can enqueue tasks" do
    daemon.enqueue { @enqueued = true }
    daemon.wait_for_tasks
    assert @enqueued
  end
end
