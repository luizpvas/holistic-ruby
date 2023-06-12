# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Solve do
  include ::SnippetParser

  context "when the clue is a namespace reference and the namespace is found via lexical scope" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Example
        end

        class Other
          Example.call
        end
      end
      RUBY
    end

    it "solves the namespace reference" do
      expect(application.symbols.find_reference_to("Example")).to have_attributes(
        itself: be_a(::Question::Ruby::TypeInference::Something),
        conclusion: have_attributes(
          itself: be_a(::Question::Ruby::TypeInference::Conclusion),
          symbol_identifier: "::MyApp::Example",
          confidence: :strong
        )
      )
    end
  end

  context "when the clue is a namespace reference and the namespace is found via ancestry scope" do
    # TODO. How?
  end

  context "when the clue is a namespace reference and the namespace does not exist" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Unknown.call
      end
      RUBY
    end

    it "leaves the conclusion empty" do
      expect(application.symbols.find_reference_to("Unknown")).to have_attributes(
        itself: be_a(::Question::Ruby::TypeInference::Something),
        conclusion: be_nil
      )
    end
  end
end
