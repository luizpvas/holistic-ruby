# frozen_string_literal: true

module Holistic::Controllers::ApplicationsController
  extend ::ActiveSupport::Concern

  Serialize = ->(application) do
    {
      name: application.name,
      root_directory: application.root_directory,
    }
  end

  included do
    get '/applications' do
      applications = ::Holistic::Ruby::Application::Repository.list_all

      applications.map(&Serialize).to_json
    end
  end
end
