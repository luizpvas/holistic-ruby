# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced with nested syntax with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::MyLib::String.new
      end
      RUBY
    end

    it "infers the scope reference clue" do
      expect(application.references.find_reference_to("MyLib::String")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            name: "MyLib::String",
            resolution_possibilities: ["::"]
          )
        ]
      )
    end
  end

  context "when a scope from stdlib is referenced with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::String.new
      end
      RUBY
    end

    it "infers a scope reference clue" do
      expect(application.references.find_reference_to("String")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            name: "String",
            resolution_possibilities: ["::"]
          )
        ]
      )
    end
  end
end
