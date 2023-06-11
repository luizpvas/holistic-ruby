# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "module declaration with nested syntax AND double colon syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module MyModule1::MyModule2
          Name.foo()
        end
      end
      RUBY
    end

    it "parses the code" do
      symbols = application.symbols.list_symbols_of(kind: :type_inference)

      expect(symbols.size).to eql(1)
      expect(symbols.first.record.clues.first).to have_attributes(
        name: "Name",
        resolution_possibilities: ["MyApp::MyModule1::MyModule2", "MyApp"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyApp" => {
            "MyModule1" => {
              "MyModule2" => {}
            }
          }
        }
      })
    end
  end
end
