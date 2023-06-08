# frozen_string_literal: true

module Question::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      application.symbol_index.delete_symbols_in_file(file.path)

      WrapParsingUnitWithProcessAtTheEnd.call(application:) do
        ParseFile.call(application:, file:)
      end
    end
  end
end
