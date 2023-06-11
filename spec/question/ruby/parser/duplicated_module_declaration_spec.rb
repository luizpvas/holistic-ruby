# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "duplicated module declaration" do
    let(:code) do
      <<-RUBY
      module MyApp
        module MyModule
          Foo1.bar()
        end

        module MyModule
          Foo2.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      symbols = application.symbol_index.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(2)

      expect(symbols[0].record.clues.first).to have_attributes(
        name: "Foo1",
        resolution_possibilities: ["MyApp::MyModule", "MyApp"]
      )

      expect(symbols[1].record.clues.first).to have_attributes(
        name: "Foo2",
        resolution_possibilities: ["MyApp::MyModule", "MyApp"]
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
