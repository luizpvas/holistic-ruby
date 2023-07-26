# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

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
      expect(application.references.find_reference_to("Name")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            resolution_possibilities: ["::MyApp::MyModule1::MyModule2", "::MyApp", "::"]
          )
        ]
      )

      expect(serialize_scope(application.root_scope)).to eql({
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
