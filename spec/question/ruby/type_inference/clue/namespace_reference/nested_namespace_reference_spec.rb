# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Clue::NamespaceReference do
  include ::SnippetParser

  context "nested namespace reference" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Example::Something.call
      end
      RUBY
    end

    it "infers namespace reference clue for the whole path" do
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)

      expect(symbols.first.record).to be_a(::Question::Ruby::TypeInference::Something)
      expect(symbols.first.record.clues.first).to have_attributes(
        itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
        name: "Example::Something",
        resolution: ["MyApp"]
      )
    end
  end
end
