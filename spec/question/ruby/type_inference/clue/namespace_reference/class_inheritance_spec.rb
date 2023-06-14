# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Clue::NamespaceReference do
  include ::SnippetParser

  context "when namespace is referenced as the parent of a class" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class MyClass < MyParent; end
      end
      RUBY
    end

    it "infers the namespace reference clue" do
      expect(application.symbols.find_reference_to("MyParent")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            name: "MyParent",
            resolution_possibilities: ["::MyApp", "::"]
          )
        ]
      )
    end
  end
end
