# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::NamespaceReference do
  include ::Support::SnippetParser

  context "when namespace is referenced on the left hand side of an assignment" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Config; end

        Config.example = 10
      end
      RUBY
    end

    # TODO: make this test pass
    # it "infers the namespace reference clue" do
    #   expect(application.symbols.find_reference_to("::MyApp::Config")).to have_attributes(
    #     clues: [
    #       have_attributes(
    #         itself: be_a(::Holistic::Ruby::TypeInference::Clue::NamespaceReference),
    #         name: "Current",
    #         resolution_possibilities: ["::MyApp", "::"]
    #       )
    #     ]
    #   )
    # end
  end
end
