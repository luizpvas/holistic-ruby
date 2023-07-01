# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  context "class declaration in the root namespace" do
    let(:application) do
      parse_snippet <<~RUBY
      class MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      expect(application.symbols.find_reference_to("Foo")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["::MyClass", "::"]
          )
        ]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyClass" => {}
        }
      })
    end
  end
end
