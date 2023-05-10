# frozen_string_literal: true

module Question::Ruby::Constant
  class Repository::References
    attr_reader :items

    def initialize()
      @items = []
    end

    delegate :size, to: :items

    def add(namespace:, name:)
      items << Reference.new(namespace:, name:)
    end

    def find(name)
      items.find { _1.name == name }
    end
  end
end