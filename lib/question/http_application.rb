# frozen_string_literal: true

require "sinatra"

class Question::HttpApplication < ::Sinatra::Base
  before { content_type :json }

  set :public_folder, ::File.expand_path("../../web-client/dist", __dir__)

  get "/health_check" do
    { status: "ok" }.to_json
  end

  get "/:application_name/namespaces" do
    application = ::Question::Ruby::Application::Repository.find(params[:application_name])

    application.root_namespace.serialize.to_json
  end
end
