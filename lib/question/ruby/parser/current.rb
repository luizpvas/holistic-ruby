# frozen_string_literal: true

require "active_support/isolated_execution_state"
require "active_support/code_generator"
require "active_support/current_attributes"

module Question::Ruby::Parser
  class Current < ::ActiveSupport::CurrentAttributes
    # TODO: Is `resolution` the best name here? Maybe something with scope? It's used for constant resolution, but it's the current scope. I dunno.
    attribute :application, :namespace, :resolution, :file, :registration_queue
  end
end
