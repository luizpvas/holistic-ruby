# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::Lifecycle::Initialized
    extend self

    def call(request)
      Current.lifecycle.initialized!

      request.drop
    end
  end
end
