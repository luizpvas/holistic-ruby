# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced with nested syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Example::Something.call
      end
      RUBY
    end

    it "infers a scope reference clue" do
      expect(application.references.find_reference_to("Example::Something")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("Example::Something"),
            resolution_possibilities: ["::MyApp", "::"]
          )
        ]
      )
    end
  end
end
