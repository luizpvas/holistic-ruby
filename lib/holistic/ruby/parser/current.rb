# frozen_string_literal: true

require "active_support/isolated_execution_state"
require "active_support/code_generator"
require "active_support/current_attributes"

module Holistic::Ruby::Parser
  class Current < ::ActiveSupport::CurrentAttributes
    attribute :application, :namespace, :constant_resolution_possibilities, :file, :registration_queue
  end
end
