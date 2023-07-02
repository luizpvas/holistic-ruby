# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  describe "class inheritance without scope resolution operator" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "parses the code" do
      expect(application.symbols.find_reference_to("MyParentClass")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            resolution_possibilities: ["::MyModule", "::"]
          )
        ]
      )

      expect(application.root_scope.serialize).to eql({
        "::" => {
          "MyModule" => {
            "MySubClass" => {}
          }
        }
      })
    end
  end
end
