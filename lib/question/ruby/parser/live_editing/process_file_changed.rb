# frozen_string_literal: true

module Question::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file_path:)
      application.symbol_index.delete_symbols_in_file(file_path)

      ParseFile.call(application:, file_path:)
    end
  end
end
