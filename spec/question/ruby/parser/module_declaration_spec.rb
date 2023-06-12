# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "module declaration in the root namespace" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      expect(application.symbols.find_reference_to("Foo")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["MyModule"]
          )
        ]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {}
        }
      })
    end
  end
end
