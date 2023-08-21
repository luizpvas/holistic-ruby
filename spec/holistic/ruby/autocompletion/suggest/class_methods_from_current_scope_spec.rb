# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Payments.process")

      actual_suggestions = described_class.call(code:, scope:)

      expected_suggestions = suggestions.map do |suggestion|
        described_class::Suggestion.new(code: suggestion[:code], kind: suggestion[:kind])
      end

      expect(actual_suggestions).to eql(expected_suggestions)
    end
  end

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      class Payments
        def self.process
          # autocompletion here
        end

        def self.method_1
        end

        private

        def self.method_2
        end
      end
    end
    RUBY
  end

  it "suggests met" do
    assert_suggestions("met", [
      { code: "method_1", kind: :class_method },
      { code: "method_2", kind: :class_method }
    ])
  end
end
