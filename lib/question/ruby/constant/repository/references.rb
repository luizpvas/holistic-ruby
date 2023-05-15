# frozen_string_literal: true

module Question::Ruby::Constant
  # TODO: Move to Question::Ruby::Constant::Reference::{Record, Collection}
  class Repository::References
    attr_reader :items

    def initialize()
      @items = []
    end

    delegate :size, to: :items

    def add(resolution:, name:)
      items << Reference.new(resolution:, name:)
    end

    def find(name)
      items.find { _1.name == name }
    end
  end
end