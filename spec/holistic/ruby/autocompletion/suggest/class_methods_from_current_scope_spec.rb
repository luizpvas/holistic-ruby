# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Payments.process")

      expression = ::Holistic::Ruby::Parser::Expression::Valid.new(code)

      actual_suggestions = described_class.for(expression:).suggest(scope:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting from class methods from current scope" do
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
        { code: "method_1", kind: "class_method" },
        { code: "method_2", kind: "class_method" }
      ])
    end
  end
end
