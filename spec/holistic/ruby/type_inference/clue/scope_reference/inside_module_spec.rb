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
      reference = application.references.find_reference_to("Example")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        expression: ::Holistic::Ruby::Parser::Expression.new("Example"),
        resolution_possibilities: ["::MyApp", "::"]
      )
    end
  end
end
