# frozen_string_literal: true

module Holistic
  class Application
    attr_reader :name, :root_directory, :database

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @database = Database::Table.new.tap(&Database::Migrations::Run)
    end

    def extensions
      @extensions ||= Extensions::Events.new
    end

    def scopes
      @scopes ||= Ruby::Scope::Repository.new(database:)
    end

    def references
      @references ||= Ruby::Reference::Repository.new(database:)
    end

    def files
      @files ||= Document::File::Repository.new(database:)
    end

    def type_inference_processing_queue
      @type_inference_processing_queue ||= Ruby::TypeInference::ProcessingQueue.new
    end

    def unsaved_documents
      @unsaved_documents ||= Document::Unsaved::Collection.new
    end
  end
end
