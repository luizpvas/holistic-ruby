# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "nested module declaration with double colon syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp::MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      reference = application.references.find_reference_to("Foo")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyApp::MyModule", "::"]
      )

      expect(serialize_scope(application.scopes.root)).to eql({
        "::" => {
          "MyApp" => {
            "MyModule" => {}
          }
        }
      })
    end
  end
end
