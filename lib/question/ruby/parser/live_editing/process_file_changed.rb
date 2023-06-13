# frozen_string_literal: true

module Question::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      application.symbols.delete_symbols_in_file(file.path)

      WrapParsingUnitWithProcessAtTheEnd.call(application:) do
        ParseFile.call(application:, file:)
      end

      binding.irb

      application.symbols.list_symbols_where_type_inference_resolves_to_file(file.path).each do |symbol|
        something = symbol.record

        something.conclusion = nil

        ::Question::Ruby::TypeInference::Solve.call(application:, something:)
      end

      application.symbols.delete_type_inference_dependencies(file.path)
    end
  end
end
