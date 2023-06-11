# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "nested module declaration with double colon syntax" do
    let(:code) do
      <<-RUBY
      module MyApp::MyModule
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
        resolution_possibilities: ["MyApp::MyModule"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyApp" => {
            "MyModule" => {}
          }
        }
      })
    end
  end
end
