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
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)

      expect(symbols.first.record).to have_attributes(
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
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)

      expect(symbols.first.record).to have_attributes(
        itself: be_a(::Question::Ruby::TypeInference::Something),
        conclusion: be_nil
      )
    end
  end
end
