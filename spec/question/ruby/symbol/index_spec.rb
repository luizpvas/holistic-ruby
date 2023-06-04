# frozen_string_literal: true

describe ::Question::Ruby::Symbol::Index do
  include ::SnippetParser

  describe "#index" do
    context "when symbol does not have source locations" do
      let(:application) { ::Question::Ruby::Application.new(name: "dummy", root_directory: ".") }
      let(:symbol) { ::Question::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations: []) }

      it "stores the symbol in the identifier index" do
        application.symbol_index.index(symbol)

        expect(application.symbol_index.find("::MySymbol")).to eql(symbol)
      end
    end

    context "when symbol has one source location" do
      let(:application) { ::Question::Ruby::Application.new(name: "dummy", root_directory: ".") }
      let(:source_locations) { [::Question::SourceCode::Location.new(file_path: "my_symbol.rb")] }
      let(:symbol) { ::Question::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations:) }

      it "stores the symbol in the identifier index" do
        application.symbol_index.index(symbol)

        expect(application.symbol_index.find("::MySymbol")).to eql(symbol)
      end

      it "stores one entry for the symbol in the file path index" do
        application.symbol_index.index(symbol)

        expect(application.symbol_index.get_symbols_in_file("my_symbol.rb")).to eql([symbol])
      end
    end

    context "when symbol has multiple source locations" do
      let(:application) { ::Question::Ruby::Application.new(name: "dummy", root_directory: ".") }

      let(:source_locations) do
        [
          ::Question::SourceCode::Location.new(file_path: "my_symbol_1.rb"),
          ::Question::SourceCode::Location.new(file_path: "my_symbol_2.rb"),
        ]
      end

      let(:symbol) { ::Question::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations:) }

      it "stores the symbol in the identifier index" do
        application.symbol_index.index(symbol)

        expect(application.symbol_index.find("::MySymbol")).to eql(symbol)
      end

      it "stores multiple entries for the symbol in the file path index" do
        application.symbol_index.index(symbol)

        expect(application.symbol_index.get_symbols_in_file("my_symbol_1.rb")).to eql([symbol])
        expect(application.symbol_index.get_symbols_in_file("my_symbol_2.rb")).to eql([symbol])
      end
    end
  end

  describe "#search" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApplication
        class MyController
          def index
            result = MyService.call(user: current_user)
          end
        end
      end
      RUBY
    end

    it "finds namespace declarations" do
      matches = application.symbol_index.search("Application")

      expect(matches[0].document).to have_attributes(
        identifier: "::MyApplication",
        text: "::MyApplication"
      )
    end

    # TODO: find references? find method declarations? find lambda declarations?
    # This should be optimized for the "I know what I'm looking for" mode, and not the exploration mode.
  end
end
