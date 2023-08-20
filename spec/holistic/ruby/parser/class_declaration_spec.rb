# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "class declaration in the root scope" do
    let(:application) do
      parse_snippet <<~RUBY
      class MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      reference = application.references.find_reference_to("Foo")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyClass", "::"]
      )

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: nil
      )

      expect(serialize_scope(application.root_scope)).to eql({
        "::" => {
          "MyClass" => {
            "new" => {}
          }
        }
      })
    end
  end
end
