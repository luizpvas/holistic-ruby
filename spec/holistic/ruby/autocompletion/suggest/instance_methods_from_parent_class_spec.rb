# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child#child_method")

      piece_of_code = ::Holistic::Ruby::Autocompletion::PieceOfCode.new(code)
      crawler = ::Holistic::Ruby::Scope::Crawler.new(scope:)

      actual_suggestions = piece_of_code.suggester.suggest(crawler:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting instance methods from parent class" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Parent
          def parent_method
          end

          def overriden_method
          end
        end

        class Child < Parent
          def child_method
            # autocomplete here
          end

          def overriden_method
          end
        end
      end
      RUBY
    end

    it "suggests p" do
      assert_suggestions("p", [
        { code: "parent_method", kind: :instance_method }
      ])
    end

    it "suggests o" do
      assert_suggestions("o", [
        { code: "overriden_method", kind: :instance_method }
      ])
    end
  end
end
