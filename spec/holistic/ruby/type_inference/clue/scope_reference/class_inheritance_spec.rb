# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced as the parent of a class" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class MyParent; end

        class MyClass < MyParent; end
      end
      RUBY
    end

    it "infers a scope reference clue" do
      reference = application.references.find_reference_to("MyParent")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("MyParent"),
        resolution_possibilities: ["::MyApp", "::"]
      )
    end

    it "sets the relation between ancestor and descentand" do
      parent_scope = application.scopes.find("::MyApp::MyParent")
      child_class  = application.scopes.find("::MyApp::MyClass")

      expect(parent_scope.descendants).to match_array([child_class])
      expect(child_class.ancestors).to match_array([parent_scope])
    end
  end
end
