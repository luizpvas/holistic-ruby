# frozen_string_literal: true

module Holistic::EmbeddedAgent
  module Bridge
    class Inline
      def publish(event_name, payload)
      end

      def subscribe(event_name, callback)
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
