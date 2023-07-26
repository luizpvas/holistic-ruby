# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "nested class declaration with double colon syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      class MyApp::MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      expect(application.references.find_reference_to("Foo")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            resolution_possibilities: ["::MyApp::MyClass", "::"]
          )
        ]
      )

      expect(serialize_scope(application.root_scope)).to eql({
        "::" => {
          "MyApp" => {
            "MyClass" => {}
          }
        }
      })
    end
  end
end
