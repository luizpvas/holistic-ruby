# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced inside module definitions" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Example.call
      end
      RUBY
    end

    it "infers a scope reference clue" do
      expect(application.references.find_reference_to("Example")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("Example"),
            resolution_possibilities: ["::MyApp", "::"]
          )
        ]
      )
    end
  end
end
