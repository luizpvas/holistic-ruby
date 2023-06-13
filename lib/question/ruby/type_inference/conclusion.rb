# frozen_string_literal: true

module Question::Ruby::TypeInference
  Conclusion = ::Struct.new(
    # TODO: rename to `dependency_identifier`
    :symbol_identifier,
    :confidence,
    keyword_init: true
  ) do
    def self.with_strong_confidence(symbol_identifier)
      new(symbol_identifier:, confidence: :strong)
    end
  end
end