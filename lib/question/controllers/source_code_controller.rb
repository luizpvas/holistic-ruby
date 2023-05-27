# frozen_string_literal: true

module Question::Controllers::SourceCodeController
  extend ::ActiveSupport::Concern
  
  included do
    get "/applications/:application_name/source_code" do
      params[:file_path]
    end
  end
end
