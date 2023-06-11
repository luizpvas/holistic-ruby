# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "class declaration in the root namespace" do
    let(:application) do
      parse_snippet <<~RUBY
      class MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)
      expect(symbols.first.record.clues.first).to have_attributes(
        name: "Foo",
        resolution_possibilities: ["MyClass"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyClass" => {}
        }
      })
    end
  end
end
