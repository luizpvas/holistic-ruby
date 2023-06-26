# frozen_string_literal: true

module Holistic::Ruby::Parser
  # TODO: Remove Array inheritance.
  class ConstantResolutionPossibilities < ::Array
    def self.root_scope 
      new(["::"])
    end

    def unshift(name)
      one? ? super("::" + name) : super(first + "::" + name)
    end

    # TODO: I think we can remove `root_scope?`.

    def root_scope?
      empty?
    end
  end
end
