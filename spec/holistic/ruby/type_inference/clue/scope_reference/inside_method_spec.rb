# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced inside class methods" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class MyClass
          def foo = Example.call
        end
      end
      RUBY
    end

    it "infers a scope reference clue" do
      reference = application.references.find_by_code_content("Example")

      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("Example"),
        resolution_possibilities: ["::MyApp::MyClass", "::MyApp", "::"]
      )
    end
  end
end
