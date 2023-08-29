# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

  context "duplicated module declaration" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module MyModule
          Foo1.bar()
        end

        module MyModule
          Foo2.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      reference_foo_1 = application.references.find_reference_to("Foo1")

      expect(reference_foo_1.attr(:clues).size).to be(1)
      expect(reference_foo_1.attr(:clues).first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
        resolution_possibilities: ["::MyApp::MyModule", "::MyApp", "::"]
      )

      reference_foo_2 = application.references.find_reference_to("Foo2")

      expect(reference_foo_2.attr(:clues).size).to be(1)
      expect(reference_foo_2.attr(:clues).first).to have_attributes(
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
