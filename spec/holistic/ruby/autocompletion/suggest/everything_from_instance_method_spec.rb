# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child#child_method")

      piece_of_code = ::Holistic::Ruby::Autocompletion::PieceOfCode.new(code)
      crawler = ::Holistic::Ruby::Scope::Crawler.new(application:, scope:)

      actual_suggestions = piece_of_code.suggester.suggest(crawler:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting everything from instance method" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Parent
          ParentLambda = ->{}

          PARENT_VALUE = 2

          def parent_method
          end
        end

        class Child < Parent
          ChildLambda = ->{}

          CHILD_VALUE = 1

          def child_method
            # autocomplete here
          end

          def sibling_method
          end
        end
      end
      RUBY
    end

    xit "suggests methods, classes, modules, lambdas and constants from the current class and ancesors" do
      assert_suggestions("", [
        { code: "child_method", kind: :instance_method },
        { code: "sibling_method", kind: :instance_method },
        { code: "parent_method", kind: :instance_method }
      ])
    end
  end
end
