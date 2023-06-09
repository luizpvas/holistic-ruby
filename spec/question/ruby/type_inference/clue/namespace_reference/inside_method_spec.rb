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
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)

      expect(symbols.first.record).to be_a(::Question::Ruby::TypeInference::Something)
      expect(symbols.first.record.clues.first).to have_attributes(
        itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
        name: "Example",
        resolution: ["MyApp::MyClass", "MyApp"]
      )
    end
  end
end
