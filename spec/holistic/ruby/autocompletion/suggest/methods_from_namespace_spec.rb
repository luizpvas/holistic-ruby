# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::EventsController#index")

      expression = ::Holistic::Ruby::Parser::Expression::Valid.new(code)

      actual_suggestions = described_class.for(expression:).suggest(scope:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting methods from namespace" do
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
      assert_suggestions("Payment.", [
        { code: "this_is_a_class_method", kind: "class_method" },
        { code: "new", kind: "class_method" }
      ])
    end

    it "suggests Payment.this" do
      assert_suggestions("Payment.this", [
        { code: "this_is_a_class_method", kind: "class_method" }
      ])
    end

    it "suggests ::MyApp::Payment." do
      assert_suggestions("::MyApp::Payment.", [
        { code: "this_is_a_class_method", kind: "class_method" },
        { code: "new", kind: "class_method" }
      ])
    end
  end
end
