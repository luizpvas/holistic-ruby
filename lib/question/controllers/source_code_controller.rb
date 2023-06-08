# frozen_string_literal: true

module Question::Controllers::SourceCodeController
  extend ::ActiveSupport::Concern

  Serialize = ->(read_source_code_result) do
    {
      file_path: read_source_code_result.file.path,
      code: read_source_code_result.file.read,
      highlight_start_line: read_source_code_result.start_line,
      highlight_end_line: read_source_code_result.end_line
    }
  end
  
  included do
    get "/applications/:application_name/source_code" do
      application = ::Question::Ruby::Application::Repository.find(params[:application_name])
      symbol_identifier = params[:symbol_identifier]

      ::Question::Ruby::Symbol::ReadSourceCode.call(application:, symbol_identifier:).then(&Serialize).to_json
    end
  end
end
