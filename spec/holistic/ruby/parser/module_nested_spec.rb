# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "nested module declaration" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module MyModule
          Foo.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      reference = application.references.find_reference_to("Foo")

      expect(reference.attr(:clues).size).to be(1)
      expect(reference.attr(:clues).first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyApp::MyModule", "::MyApp", "::"]
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
