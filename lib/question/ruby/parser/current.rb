# frozen_string_literal: true

require "active_support/isolated_execution_state"
require "active_support/code_generator"
require "active_support/current_attributes"

module Question::Ruby::Parser
  class Current < ::ActiveSupport::CurrentAttributes
    attribute :application, :file_path
  end
end
