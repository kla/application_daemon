require "concurrent"

module ApplicationDaemon
  module Queue
    class Task
      attr_reader :name, :future

      def initialize(name:, future:, &block)
        @name = name || block.to_s
        @future = future
      end

      def completed?
        future.fulfilled?
      end

      def value
        future.value
      end
    end

    module InstanceMethods
      def queue
        @queue ||= [ ]
      end

      def executor
        @executor ||= ::Concurrent::ThreadPoolExecutor.new(min_threads: min_threads, max_threads: max_threads, max_queue: max_queue)
      end

      def enqueue(name: nil, &block)
        queue << Task.new(name: name, future: ::Concurrent::Future.execute(executor: executor, &block))
      end

      def min_threads
        options.fetch(:min_threads, Concurrent.processor_count)
      end

      def max_threads
        options.fetch(:min_threads, Concurrent.processor_count)
      end

      def max_queue
        options.fetch(:max_queue, max_threads * 5)
      end

      def can_enqueue?
        queue.length < max_queue
      end

      def remove_completed
        queue.reject!(&:completed?)
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
