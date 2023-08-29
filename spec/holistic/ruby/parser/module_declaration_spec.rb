# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "module declaration in the root scope" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      reference = application.references.find_reference_to("Foo")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyModule", "::"]
      )

      expect(serialize_scope(application.scopes.root)).to eql({
        "::" => {
          "MyModule" => {}
        }
      })
    end
  end
end
