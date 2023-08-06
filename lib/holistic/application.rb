# frozen_string_literal: true

module Holistic
  class Application
    attr_reader :name, :root_directory, :root_scope

    class Events
      def initialize
        @listeners = Hash.new{ |hash, key| hash[key] = [] }
      end

      def listen(event, &callback)
        @listeners[event] << callback
      end

      def dispatch(event, **args)
        @listeners[event].lazy.filter_map { |callback| callback.call(**args) }.first
      end
    end

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_scope = Ruby::Scope::Record.new(kind: Ruby::Scope::Kind::ROOT, name: "::", parent: nil)
    end

    def events
      @events ||= Events.new
    end

    def scopes
      @scopes ||= Ruby::Scope::Repository.new
    end

    def references
      @references ||= Ruby::Reference::Repository.new
    end

    def unsaved_documents
      @unsaved_documents ||= Document::Unsaved::Collection.new
    end
  end
end
