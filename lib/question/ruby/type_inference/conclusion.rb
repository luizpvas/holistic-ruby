# frozen_string_literal: true

module Question::Ruby::TypeInference
  Conclusion = ::Struct.new(
    :symbol,
    :confidence,
    keyword_init: true
  ) do
    def self.with_strong_confidence(symbol)
      new(symbol:, confidence: :strong)
    end
  end
end