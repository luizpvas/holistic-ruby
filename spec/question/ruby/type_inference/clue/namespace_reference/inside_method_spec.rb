# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Clue::NamespaceReference do
  include ::SnippetParser

  context "when namespace is referenced inside class method" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class MyClass
          def foo = Example.call
        end
      end
      RUBY
    end

    it "infers the namespace reference clue" do
      expect(application.symbols.find_reference_to("Example")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            name: "Example",
            resolution_possibilities: ["MyApp::MyClass", "MyApp"]
          )
        ]
      )
    end
  end
end
