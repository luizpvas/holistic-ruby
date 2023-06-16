# frozen_string_literal: true

require "sinatra"
require "sinatra/cors"
require "active_support/concern"
require "active_support/core_ext/module/concerning"
require "logger"

class Holistic::HttpApplication < ::Sinatra::Base
  concerning :Logging do
    def logger
      @logger ||= ::Logger.new(STDOUT)
    end
  end

  concerning :CORS do
    included do
      register ::Sinatra::Cors

      set :allow_origin, "*"
      set :allow_methods, "GET,POST"
      set :allow_headers, "Content-Type"
      set :expose_headers, "*"
    end
  end

  concerning :Routes do
    included do
      before { content_type :json }
    end

    include ::Holistic::Controllers::HealthCheckController
    include ::Holistic::Controllers::ApplicationsController
    include ::Holistic::Controllers::NamespacesController
    include ::Holistic::Controllers::SearchController
    include ::Holistic::Controllers::SourceCodeController
  end

  concerning :WebClient do
    included do
      set(:public_folder, ::File.expand_path("../../web-client/dist", __dir__))
    end
  end
end
