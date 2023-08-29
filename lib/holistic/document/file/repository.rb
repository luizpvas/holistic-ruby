# frozen_string_literal: true

class ::Holistic::Document::File::Repository
  def initialize(database:)
    @database = database

    @database.define_connection(name: :defines_scopes, inverse_of: :scope_defined_in_file)
    @database.define_connection(name: :defines_references, inverse_of: :reference_defined_in_file)
  end

  # rename to `store_file`
  def store(file_path)
    @database.store(file_path, { path: file_path })
  end

  # rename to `delete_file`
  def delete(file_path)
    @database.delete(file_path)
  end

  # rename to `find_file`
  def find(file_path)
    @database.find(file_path)
  end

  concerning :TestHelpers do
    def build_fake_location(file_path)
      file = store(file_path)

      ::Holistic::Document::Location.new(file, 0, 0, 0, 0)
    end
  end
end
