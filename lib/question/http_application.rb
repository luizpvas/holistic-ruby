# frozen_string_literal: true

require "sinatra"

class Question::HttpApplication < ::Sinatra::Base
  before { content_type :json }

  set :public_folder, ::File.expand_path("../../web-client/dist", __dir__)

  get "/health_check" do
    { status: "ok" }.to_json
  end
end
