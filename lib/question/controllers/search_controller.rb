# frozen_string_literal: true

module Question::Controllers::SearchController
  extend ::ActiveSupport::Concern

  included do
    get "/applications/:application_name/search" do
      
    end
  end
end