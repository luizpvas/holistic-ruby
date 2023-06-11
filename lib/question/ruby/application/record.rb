# frozen_string_literal: true

module Question::Ruby
  class Application::Record
    attr_reader :name, :root_directory, :root_namespace

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_namespace = Namespace::Record.new(kind: :root, name: "::", parent: nil)
    end

    # TODO: rename to `symbols`? I think it reads better. `application.symbols.find("::MyApp")`.
    # Perhapes `Symbol::Index` should be renamed to `Symbol::Collection`?
    def symbol_index
      @symbol_index ||= Symbol::Index.new(application: self)
    end

    def files
      @files ||= ::Question::SourceCode::File::Collection.new(application: self)
    end
  end
end
