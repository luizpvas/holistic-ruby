# frozen_string_literal: true

module Question::Controllers::SourceCodeController
  extend ::ActiveSupport::Concern

  # TODO: Move to shared place?
  SerializeSourceLocation = ->(source_location) do
    {
      file_path: source_location.file_path,
      start_line: source_location.start_line,
      start_column: source_location.start_column,
      end_line: source_location.end_line,
      end_column: source_location.end_column
    }
  end

  # TODO: Move to shared place?
  SerializeSymbol = ->(symbol) do
    serialized_subtype =
      case symbol.record
      when ::Question::Ruby::Namespace::Record
        { fully_qualified_name: symbol.record.fully_qualified_name }
      when ::Question::Ruby::TypeInference::Something
        { dependency_identifier: symbol.record.conclusion&.dependency_identifier }
      else
        raise ::NotImplementedError, "unknown symbol subtype: #{symbol.record.inspect}"
      end

    {
      identifier: symbol.identifier,
      source_locations: symbol.source_locations.map(&SerializeSourceLocation),
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
      application = ::Question::Ruby::Application::Repository.find(params[:application_name])
      symbol_identifier = params[:symbol_identifier]

      ::Question::Ruby::Symbol::ReadSourceCode.call(application:, symbol_identifier:).then(&Serialize).to_json
    end

    post "/applications/:application_name/source_code" do
      application = ::Question::Ruby::Application::Repository.find(params[:application_name])

      payload = JSON.parse(request.body.read)

      file = application.files.find(payload["file_path"])

      file.write(payload["content"])

      ::Question::Ruby::Symbol::ReadSourceCode.call(application:, file_path: file.path).then(&Serialize).to_json
    end
  end
end
