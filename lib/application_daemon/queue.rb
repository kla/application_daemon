require "concurrent"

module ApplicationDaemon
  module Queue
    module InstanceMethods
      def queue
        @queue ||= [ ]
      end

      def enqueue(&block)
        queue << ::Concurrent::Future.execute(&block)
      end

      def can_enqueue?
        queue.length < 50
      end

      def remove_completed
        queue.reject!(&:fulfilled?)
      end

      def wait_for_tasks
        queue.map(&:value)
      end
    end

    def self.included(base)
      base.every(:tick, at_start: false) { remove_completed }
      base.send(:include, InstanceMethods)
    end
  end
end
