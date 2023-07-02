# frozen_string_literal: true

module Holistic
  class Application
    attr_reader :name, :root_directory, :root_scope

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_scope = Ruby::Scope::Record.new(kind: Ruby::Scope::Kind::ROOT, name: "::", parent: nil)
    end

    def symbols
      @symbols ||= Ruby::Symbol::Collection.new(application: self)
    end

    def dependencies
      @dependencies ||= Ruby::TypeInference::Dependencies.new(application: self)
    end

    def unsaved_documents
      @unsaved_documents ||= Document::Unsaved::Collection.new
    end
  end
end
