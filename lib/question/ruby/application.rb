# frozen_string_literal: true

module Question::Ruby
  class Application
    attr_reader :constant_repository

    def initialize
      @constant_repository = Constant::Repository.new
    end
  end
end
