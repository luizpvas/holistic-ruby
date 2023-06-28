# frozen_string_literal: true

module Holistic::LanguageServer
  Message = ::Data.define(:data) do
    def params
      data["params"]
    end

    def param(*keys)
      data["params"].dig(*keys)
    end

    def method
      data["method"]
    end

    def id
      data["id"]
    end
  end
end
