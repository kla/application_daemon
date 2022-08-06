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

  it "removes completed tasks" do
    daemon.enqueue { }
    daemon.wait_for_tasks
    assert_equal 1, daemon.queue.length
    daemon.remove_completed
    assert_equal 0, daemon.queue.length
  end

  it "accepts a :name option" do
    daemon.enqueue(name: "eh") { }
    assert_equal "eh", daemon.queue[0].name
  end
end
