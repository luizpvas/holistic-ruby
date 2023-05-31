# frozen_string_literal: true

module Question::Ruby::Symbol
  class InvertedIndex
    attr_reader :application, :data

    def initialize(application:)
      @application = application
      @data = ::Hash.new { |hash, key| hash[key] = [] }
    end

    def index(key, symbol)
      raise ::ArgumentError, "#{key.inspect} must be a string" unless key.is_a?(::String)
      raise ::ArgumentError, "#{symbol.inspect} must be a symbol" unless symbol.is_a?(Record)

      @data[key] << symbol
    end
  end
end
