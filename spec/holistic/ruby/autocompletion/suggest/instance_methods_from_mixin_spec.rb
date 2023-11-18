# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child#child_method")

      expression = ::Holistic::Ruby::Parser::Expression::Valid.new(code)

      actual_suggestions = described_class.for(expression:).suggest(scope:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting instance methods from mixin" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module Parent_1
          def parent_1_method
          end
        end

        module Parent_2
          def parent_2_method
          end
        end

        class Child
          include Parent_1
          include Parent_2

          def child_method
            # autocomplete here
          end
        end
      end
      RUBY
    end

    it "suggests p" do
      assert_suggestions("p", [
        { code: "parent_1_method", kind: "instance_method" },
        { code: "parent_2_method", kind: "instance_method" }
      ])
    end
  end
end
