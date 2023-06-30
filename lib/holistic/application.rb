# frozen_string_literal: true

module Holistic
  class Application
    attr_reader :name, :root_directory, :root_namespace

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_namespace = Ruby::Namespace::Record.new(kind: Ruby::Namespace::Kind::ROOT, name: "::", parent: nil)
    end

    def symbols
      @symbols ||= Ruby::Symbol::Collection.new(application: self)
    end

    def dependencies
      @dependencies ||= Ruby::TypeInference::Dependencies.new(application: self)
    end

    # TODO: I think Buffers is a good name. It has a nice contrast with File.
    # But calling this collection `documents` might be a bit misleading. They are the currently open documents,
    # usually visible as tabs in editors.
    #
    # There has to be a better name.
    def documents
      @documents ||= Document::Buffers.new
    end
  end
end
