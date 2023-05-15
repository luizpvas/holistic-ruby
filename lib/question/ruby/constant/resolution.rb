# frozen_string_literal: true

module Question::Ruby::Constant
  # TODO: Remove Array inheritance.
  class Resolution < ::Array
    def unshift(name)
      if empty?
        super(name)
      else
        super(join("::") + "::" + name)
      end
    end
  end
end
