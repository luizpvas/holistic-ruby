# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  describe "class inheritance without scope resolution operator" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "parses the code" do
      expect(application.symbols.find_reference_to("MyParentClass")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["::MyModule", "::"]
          )
        ]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {
            "MySubClass" => {}
          }
        }
      })
    end
  end
end
