# frozen_string_literal: true

module Question::Ruby::Parser::LiveEditing
  module ProcessFileChanged
    extend self

    def call(application:, file_path:)
      application.symbol_index.delete_symbols_in_file(file_path)

      parse_again(application:, file_path:)
    end

    private

    def parse_again(application:, file_path:)
      raise "todo"
    end
  end
end
