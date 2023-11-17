# frozen_string_literal: true

module Holistic::EmbeddedAgent
  class Subscriber
    def self.subscribe(application:)
      subscriber = new(application:)

      Event::FORMATS.keys.each do |event_name|
        application.bridge.subscribe(event_name, subscriber.method(event_name.to_sym))
      end

      subscriber
    end

    attr_reader :application

    def initialize(application:)
      @application = application
    end

    private

    def register_constant(payload)
      lexical_parent =
        if payload[:fully_qualified_lexical_parent].nil?
          application.scopes.root
        else
          application.scopes.find(payload[:fully_qualified_lexical_parent])
        end

      kind = payload[:kind] # TODO: validate kind
      name = payload[:name]
      location = ::Holistic::Ruby::Scope::Location.external(application:)

      ::Holistic::Ruby::Scope::Store.call(
        database: application.database,
        lexical_parent:,
        kind:,
        name:,
        location:
      )
    end

    def register_instance_method(payload)
      raise "todo"
    end

    def register_class_method(payload)
      raise "todo"
    end
  end
end
