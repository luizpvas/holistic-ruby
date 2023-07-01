# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::NamespaceReference do
  include ::Support::SnippetParser

  context "nested namespace reference" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Example::Something.call
      end
      RUBY
    end

    it "infers namespace reference clue for the whole path" do
      expect(application.symbols.find_reference_to("Example::Something")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            name: "Example::Something",
            resolution_possibilities: ["::MyApp", "::"]
          )
        ]
      )
    end
  end
end
