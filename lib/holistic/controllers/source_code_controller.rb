# frozen_string_literal: true

module Holistic::Controllers::SourceCodeController
  extend ::ActiveSupport::Concern

  # TODO: Move to shared place?
  SerializeLocation = ->(location) do
    {
      file_path: location.file_path,
      start_line: location.start_line,
      start_column: location.start_column,
      end_line: location.end_line,
      end_column: location.end_column
    }
  end

  # TODO: Move to shared place?
  SerializeSymbol = ->(symbol) do
    serialized_subtype =
      case symbol.record
      when ::Holistic::Ruby::Namespace::Record
        { fully_qualified_name: symbol.record.fully_qualified_name }
      when ::Holistic::Ruby::TypeInference::Reference
        { dependency_identifier: symbol.record.conclusion&.dependency_identifier }
      when ::Holistic::Ruby::Declaration::Record
        {} # TODO: what should be here?
      else
        raise ::NotImplementedError, "unknown symbol subtype: #{symbol.record.inspect}"
      end

    {
      identifier: symbol.identifier,
      locations: symbol.locations.map(&SerializeLocation),
      kind: symbol.kind.to_s
    }.merge(serialized_subtype)
  end

  Serialize = ->(read_source_code_result) do
    {
      file_path: read_source_code_result.file.path,
      symbols: read_source_code_result.symbols.map(&SerializeSymbol),
      code: read_source_code_result.file.read,
      highlight_start_line: read_source_code_result.start_line,
      highlight_start_column: read_source_code_result.start_column,
      highlight_end_line: read_source_code_result.end_line,
      highlight_end_column: read_source_code_result.end_column
    }
  end
  
  included do
    get "/applications/:application_name/source_code" do
      application = ::Holistic::Ruby::Application::Repository.find(params[:application_name])
      symbol_identifier = params[:symbol_identifier]

      ::Holistic::Ruby::Symbol::ReadSourceCode.call(application:, symbol_identifier:).then(&Serialize).to_json
    end

    # TODO: extract this logic to a use case
    post "/applications/:application_name/source_code" do
      application = ::Holistic::Ruby::Application::Repository.find(params[:application_name])

      payload = JSON.parse(request.body.read)

      file = application.files.find(payload["file_path"])

      file.write(payload["content"])

      ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(application:, file:)

      ::Holistic::Ruby::Symbol::ReadSourceCode.call(application:, file_path: file.path).then(&Serialize).to_json
    end
  end
end
