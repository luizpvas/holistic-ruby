# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include SnippetParser

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
      expect(application.symbols.find_reference_to("Foo1")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["::MyApp::MyModule", "::MyApp", "::"]
          )
        ]
      )

      expect(application.symbols.find_reference_to("Foo2")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["::MyApp::MyModule", "::MyApp", "::"]
          )
        ]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyApp" => {
            "MyModule" => {}
          }
        }
      })
    end
  end
end
