# frozen_string_literal: true

module Question::Ruby
  class Application
    attr_reader :constant_registry

    def initialize
      @constant_registry = Constant::Registry.new
    end
  end
end
