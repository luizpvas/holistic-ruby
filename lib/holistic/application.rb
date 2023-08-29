# frozen_string_literal: true

module Holistic
  class Application
    attr_reader :name, :root_directory, :database

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @database = Database::Table.new

      # scope parent-children relation
      @database.define_connection(name: :children, inverse_of: :parent)

      # type inference conclusion
      @database.define_connection(name: :referenced_scope, inverse_of: :referenced_by)

      # reference definition
      @database.define_connection(name: :located_in_scope, inverse_of: :contains_many_references)

      # scope location
      @database.define_connection(name: :defines_scopes, inverse_of: :scope_defined_in_file)

      # reference location
      @database.define_connection(name: :defines_references, inverse_of: :reference_defined_in_file)
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
