# frozen_string_literal: true

module Question::Ruby::TypeInference
  Conclusion = ::Struct.new(
    :dependency_identifier,
    :confidence,
    keyword_init: true
  ) do
    def self.with_strong_confidence(dependency_identifier)
      new(dependency_identifier:, confidence: :strong)
    end
  end
end