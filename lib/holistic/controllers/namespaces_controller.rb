# frozen_string_literal: true

module Holistic::Controllers::NamespacesController
  extend ::ActiveSupport::Concern

  included do
    get "/applications/:application_name/namespaces" do
      application = ::Holistic::Ruby::Application::Repository.find(params[:application_name])

      application.root_namespace.serialize.to_json
    end
  end
end