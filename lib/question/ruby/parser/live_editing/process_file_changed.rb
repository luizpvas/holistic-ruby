# frozen_string_literal: true

module Question::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      delete_symbols_in_file(application:, file:)
      parse_again(application:, file:)
      recalculate_dependants_of_file(application:, file:)
    end

    private

    def delete_symbols_in_file(application:, file:)
      application.symbols.delete_symbols_in_file(file.path)
    end

    def parse_again(application:, file:)
      WrapParsingUnitWithProcessAtTheEnd.call(application:) do
        ParseFile.call(application:, file:)
      end
    end

    def recalculate_dependants_of_file(application:, file:)
      symbols = application.symbols.list_symbols_where_type_inference_resolves_to_file(file.path)

      application.symbols.delete_type_inference_dependencies(file.path)

      symbols.each do |symbol|
        something = symbol.record

        something.conclusion = nil

        ::Question::Ruby::TypeInference::Solve.call(application:, something:)
      end
    end
  end
end
