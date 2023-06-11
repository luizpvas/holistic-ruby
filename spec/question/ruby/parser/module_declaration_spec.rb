# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "module declaration in the root namespace" do
    let(:code) do
      <<-RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)
      expect(symbols.first.record.clues.first).to have_attributes(
        name: "Foo",
        resolution_possibilities: ["MyModule"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {}
        }
      })
    end
  end
end
