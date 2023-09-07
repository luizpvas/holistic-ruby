# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Solver::Scope
  extend self

  def solve(application:, nesting:, resolution_possibilities:)
    resolution_possibilities = ["::"] if nesting.root_scope_resolution?

    resolution_possibilities.each do |resolution_candidate|
      fully_qualified_scope_name =
        if resolution_candidate == "::"
          "::#{nesting.to_s}"
        else
          "#{resolution_candidate}::#{nesting.to_s}"
        end

      scope = application.scopes.find(fully_qualified_scope_name)

      return scope if scope.present?
    end

    nil
  end
end
