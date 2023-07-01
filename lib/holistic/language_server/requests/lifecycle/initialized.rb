# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::Lifecycle::Initialized
    extend self

    def call(request)
      Current.lifecycle.initialized!

      request.respond_with(nil)
    end
  end
end
