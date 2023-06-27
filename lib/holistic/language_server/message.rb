# frozen_string_literal: true

module Holistic::LanguageServer
  class Message
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def params
      @data["params"]
    end

    def param(*keys)
      @data["params"].dig(*keys)
    end

    def method
      @data["method"]
    end

    def id
      @data["id"]
    end
  end
end
