# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  context "module declaration in the root scope" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      expect(application.references.find_reference_to("Foo")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Holistic::Ruby::TypeInference::Clue::ScopeReference),
            resolution_possibilities: ["::MyModule", "::"]
          )
        ]
      )

      expect(application.root_scope.serialize).to eql({
        "::" => {
          "MyModule" => {}
        }
      })
    end
  end
end
