# frozen_string_literal: true

require "active_support/isolated_execution_state"
require "active_support/code_generator"
require "active_support/current_attributes"

module Holistic::LanguageServer
  class Current < ::ActiveSupport::CurrentAttributes
    attribute :application, :lifecycle
  end
end
