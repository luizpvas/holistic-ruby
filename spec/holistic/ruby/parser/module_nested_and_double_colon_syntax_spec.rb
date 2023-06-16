# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include SnippetParser

  context "module declaration with nested syntax AND double colon syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module MyModule1::MyModule2
          Name.foo()
        end
      end
      RUBY
    end

    it "parses the code" do
      expect(application.symbols.find_reference_to("Name")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
            resolution_possibilities: ["::MyApp::MyModule1::MyModule2", "::MyApp", "::"]
          )
        ]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyApp" => {
            "MyModule1" => {
              "MyModule2" => {}
            }
          }
        }
      })
    end
  end
end
