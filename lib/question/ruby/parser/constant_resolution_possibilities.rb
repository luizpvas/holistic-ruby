# frozen_string_literal: true

module Question::Ruby::Parser
  # TODO: Remove Array inheritance.
  class ConstantResolutionPossibilities < ::Array
    def self.root_scope
      new
    end

    def unshift(name)
      if empty?
        super(name)
      else
        super(join("::") + "::" + name)
      end
    end

    def root_scope?
      empty?
    end
  end
end
