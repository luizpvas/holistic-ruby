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

  context "when suggesting instance methods from current scope" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class EventsController
          Lambda1 = ->{ nil }

          def index
            # autocomplete here
          end

          def method_1
          end

          private

          def method_2
          end
        end
      end
      RUBY
    end

    it "suggests met" do
      assert_suggestions("met", [
        { code: "method_1", kind: :instance_method },
        { code: "method_2", kind: :instance_method }
      ])
    end

    it "suggests Lam" do
      assert_suggestions("Lam", [
        { code: "Lambda1", kind: :lambda }
      ])
    end
  end
end
