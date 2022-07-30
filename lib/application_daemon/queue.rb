require "concurrent"

module ApplicationDaemon
  module Queue
    module InstanceMethods
      def queue
        @queue ||= [ ]
      end

      def executor
        @executor ||= ::Concurrent::ThreadPoolExecutor.new(
          min_threads: options.fetch(:min_threads, Concurrent.processor_count),
          max_threads: options.fetch(:max_threads, Concurrent.processor_count),
          max_queue: max_queue,
        )
      end

      def enqueue(&block)
        queue << ::Concurrent::Future.execute(executor: executor, &block)
      end

      def max_queue
        options.fetch(:max_queue, Concurrent.processor_count * 5)
      end

      def can_enqueue?
        queue.length < max_queue
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
