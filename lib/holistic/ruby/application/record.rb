# frozen_string_literal: true

module Holistic::Ruby
  class Application::Record
    attr_reader :name, :root_directory, :root_namespace

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_namespace = Namespace::Record.new(kind: :root, name: "::", parent: nil)
    end

    def symbols
      @symbols ||= Symbol::Collection.new(application: self)
    end

    def dependencies
      @dependencies ||= TypeInference::Dependencies.new(application: self)
    end

    def files
      @files ||= ::Holistic::File::Collection.new(application: self)
    end
  end
end
