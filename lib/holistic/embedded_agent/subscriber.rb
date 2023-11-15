# frozen_string_literal: true

module Holistic::EmbeddedAgent
  class Subscriber
    def initialize(application:, bridge:)
      @application = application

      Event::FORMATS.keys.each do |event_name|
        bridge.subscribe(event_name, method(event_name.to_sym))
      end
    end

    def register_constant(payload)
      raise "todo"
    end

    def register_instance_method(payload)
      raise "todo"
    end

    def register_class_method(payload)
      raise "todo"
    end
  end
end
