# frozen_string_literal: true

require "sinatra"
require "active_support/concern"

class Question::HttpApplication < ::Sinatra::Base
  before { content_type :json }

  set :public_folder, ::File.expand_path("../../web-client/dist", __dir__)

  include ::Question::Controllers::HealthCheckController
  include ::Question::Controllers::ApplicationsController
  include ::Question::Controllers::NamespacesController
end
