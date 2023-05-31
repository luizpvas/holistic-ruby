# frozen_string_literal: true

module Question::Ruby::Symbol
  class InvertedIndex
    attr_reader :application, :data

    def initialize(application:)
      @application = application
      @data = ::Hash.new { |hash, key| hash[key] = [] }
    end

    def index(key, symbol)
      @data[key] << symbol
    end

    def destroy(key)
      @data.delete(key)
    end
  end
end
