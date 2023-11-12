# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  describe "class inheritance without scope resolution operator" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "parses the code" do
      reference = application.references.find_reference_to("MyParentClass")

      expect(reference.clues.size).to be(2)
      expect(reference.clues[0]).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyModule", "::"]
      )
      expect(reference.clues[1]).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ReferenceToSuperclass),
        subclass_scope: have_attributes(fully_qualified_name: "::MyModule::MySubClass")
      )

      expect(serialize_scope(application.scopes.root)).to eql({
        "::" => {
          "MyModule" => {
            "MySubClass" => {
              "new" => {}
            }
          }
        }
      })
    end
  end
end
