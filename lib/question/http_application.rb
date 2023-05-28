# frozen_string_literal: true

require "sinatra"
require "sinatra/cors"
require "active_support/concern"
require "active_support/core_ext/module/concerning"

class Question::HttpApplication < ::Sinatra::Base
  concerning :Cors do
    included do
      register Sinatra::Cors

      set :allow_origin, "*"
      set :allow_methods, "*"
      set :allow_headers, "*"
      set :expose_headers, "*"
    end
  end

  concerning :JsonApi do
    included do
      before { content_type :json }
    end

    include ::Question::Controllers::HealthCheckController
    include ::Question::Controllers::ApplicationsController
    include ::Question::Controllers::NamespacesController
    include ::Question::Controllers::SearchController
    include ::Question::Controllers::SourceCodeController
  end

  concerning :Frontend do
    included do
      set(:public_folder, ::File.expand_path("../../web-client/dist", __dir__))
    end
  end
end
