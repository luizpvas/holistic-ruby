# frozen_string_literal: true

module Question::Ruby::Parser
  # TODO: Remove Array inheritance.
  class ConstantResolutionPossibilities < ::Array
    def unshift(name)
      if empty?
        super(name)
      else
        super(join("::") + "::" + name)
      end
    end
  end
end
