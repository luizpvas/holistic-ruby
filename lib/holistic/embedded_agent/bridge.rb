# frozen_string_literal: true

module Holistic::EmbeddedAgent
  module Bridge
    class Inline
      def initialize
        @subscribers = {}
      end

      def publish(event_name, payload)
        @subscribers[event_name].call(payload)
      end

      def subscribe(event_name, callback)
        raise ::ArgumentError if @subscribers.key?(event_name)

        @subscribers[event_name] = callback
      end
    end

    class FileStream
      def publish(event_name, payload)
      end

      def subscribe(event_name, callback)
      end
    end
  end
end
