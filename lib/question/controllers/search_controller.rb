# frozen_string_literal: true

module Question::Controllers::SearchController
  extend ::ActiveSupport::Concern

  Serialize = ->(match) do
    {
      identifier: match.document.identifier,
      text: match.document.text,
      highlighted_text: match.highlighted_text,
      score: match.score
    }
  end

  included do
    get "/applications/:application_name/search" do
      application = ::Question::Ruby::Application::Repository.find(params[:application_name])

      application.symbol_index.search(params[:query]).map(&Serialize).to_json
    end
  end
end