# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::EventsController#index")

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
      class Payment
        def self.this_is_a_class_method
        end

        def this_is_an_instance_method
        end
      end

      Payout = ::Data.define do
      end

      Calculate = ->(a, b) { a + b }

      class EventsController
        module Feed
          module Item; end
        end

        def index
          # autocomplete here
        end
      end
    end
    RUBY
  end

  it "suggests Payment." do
    assert_suggestions("Payment.", [{ code: "this_is_a_class_method", kind: :class_method }])
  end
end
