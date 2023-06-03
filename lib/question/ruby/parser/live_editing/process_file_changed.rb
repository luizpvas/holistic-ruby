# frozen_string_literal: true

module Question::Ruby::Parser::LiveEditing
  module ProcessFileChanged
    extend self

    def call(application:, file_path:)
      delete_all_symbols_defined_in_file(application:, file_path:)
      parse_again(application:, file_path:)
    end

    private

    def delete_all_symbols_defined_in_file(application:, file_path:)
      raise "todo"
    end

    def parse_again(application:, file_path:)
      raise "todo"
    end
  end
end
