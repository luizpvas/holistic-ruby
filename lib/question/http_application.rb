# frozen_string_literal: true

require "sinatra"

class Question::HttpApplication < ::Sinatra::Base
  before { content_type :json }

  get "/health_check" do
    { status: "ok" }.to_json
  end
end
