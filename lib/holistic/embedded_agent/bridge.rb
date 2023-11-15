# frozen_string_literal: true

module Holistic::EmbeddedAgent
  module Bridge
    class Inline
      def send(event_name, payload)
      end
    end

    class FileStream
      def send(event_name, payload)
      end
    end
  end
end
