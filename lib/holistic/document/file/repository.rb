# frozen_string_literal: true

class ::Holistic::Document::File::Repository
  def initialize
    @table = ::Holistic::Database::Table.new
  end

  def store(file)
    @table.store(file.path, { file: })
  end

  def delete(path)
    @table.delete(path)
  end

  def find(path)
    @table.find(path)&.then { _1[:file] }
  end

  concerning :TestHelpers do
    def all
      @table.all
    end
  end
end
