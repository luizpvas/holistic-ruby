# frozen_string_literal: true

module Question::Controllers::HealthCheckController
  extend ::ActiveSupport::Concern

  included do
    get "/health_check" do
      { status: "ok" }.to_json
    end
  end
end