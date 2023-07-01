# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::NamespaceReference do
  include ::Support::SnippetParser

  context "when namespace is referenced inside module definition" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Example.call
      end
      RUBY
    end

    it "infers the namespace reference clue" do
      expect(application.symbols.find_reference_to("Example")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            name: "Example",
            resolution_possibilities: ["::MyApp", "::"]
          )
        ]
      )
    end
  end
end
