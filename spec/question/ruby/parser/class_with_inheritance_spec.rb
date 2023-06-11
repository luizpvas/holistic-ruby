# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  describe "class inheritance without scope resolution operator" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "parses the code" do
      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)
      expect(symbols.first.record.clues.first).to have_attributes(
        name: "MyParentClass",
        resolution_possibilities: ["MyModule"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {
            "MySubClass" => {}
          }
        }
      })
    end
  end
end
