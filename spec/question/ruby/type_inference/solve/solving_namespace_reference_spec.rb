# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Solve do
  include ::SnippetParser

  context "when the referenced namespace is declared in the same file" do
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

    it "does not register a dependency" do
      expect(application.symbols.list_symbols_where_type_inference_resolves_to_file("snippet.rb")).to be_empty
    end
  end

  context "when the referenced namespace is declared in another file" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "my_app/example.rb", <<~RUBY
        module MyApp
          class Example; end
        end
        RUBY

        files.add "my_app/other.rb", <<~RUBY
        module MyApp
          module Other
            Example.call
          end
        end
        RUBY
      end
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

    it "registers a dependency" do
      symbols = application.symbols.list_symbols_where_type_inference_resolves_to_file("my_app/example.rb")

      expect(symbols.size).to eql(1)
      expect(symbols.first.record).to eql(application.symbols.find_reference_to("Example"))
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
