# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Collection do
  include ::SnippetParser

  describe "#index" do
    context "when symbol does not have source locations" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations: []) }

      it "stores the symbol in the identifier index" do
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
      end
    end

    context "when symbol has one source location" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }
      let(:source_locations) { [::Holistic::SourceCode::Location.new(file_path: "my_symbol.rb")] }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations:) }

      it "stores the symbol in the identifier index" do
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
      end

      it "stores one entry for the symbol in the file path index" do
        application.symbols.index(symbol)

        expect(application.symbols.list_symbols_in_file("my_symbol.rb")).to eql([symbol])
      end
    end

    context "when symbol has multiple source locations" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }

      let(:source_locations) do
        [
          ::Holistic::SourceCode::Location.new(file_path: "my_symbol_1.rb"),
          ::Holistic::SourceCode::Location.new(file_path: "my_symbol_2.rb"),
        ]
      end

      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations:) }

      it "stores the symbol in the identifier index" do
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
      end

      it "stores multiple entries for the symbol in the file path index" do
        application.symbols.index(symbol)

        expect(application.symbols.list_symbols_in_file("my_symbol_1.rb")).to eql([symbol])
        expect(application.symbols.list_symbols_in_file("my_symbol_2.rb")).to eql([symbol])
      end
    end

    context "when indexing the same symbol with the same source locations multiple times" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }
      let(:source_location) { ::Holistic::SourceCode::Location.new(file_path: "my_symbol_1.rb") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations: [source_location]) }

      it "does nothing" do
        application.symbols.index(symbol)
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
        expect(application.symbols.list_symbols_in_file("my_symbol_1.rb").to_a).to eql([symbol])
      end
    end

    context "when indexing the same symbol multiple times with extra source locations" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }
      let(:source_location_1) { ::Holistic::SourceCode::Location.new(file_path: "my_symbol_1.rb") }
      let(:source_location_2) { ::Holistic::SourceCode::Location.new(file_path: "my_symbol_2.rb") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", source_locations: [source_location_1]) }

      it "does nothing" do
        application.symbols.index(symbol)

        symbol.source_locations << source_location_2

        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
        expect(application.symbols.list_symbols_in_file("my_symbol_1.rb").to_a).to eql([symbol])
        expect(application.symbols.list_symbols_in_file("my_symbol_2.rb").to_a).to eql([symbol])
      end
    end
  end

  describe "#delete_symbols_in_file" do
    context "when file is not indexed" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }

      it "does nothing" do
        expect(application.symbols.delete_symbols_in_file("non_existing.rb").to_a).to eql([])
      end
    end

    context "when file has symbols" do
      let(:application) { ::Holistic::Ruby::Application::Record.new(name: "dummy", root_directory: ".") }

      let(:source_location) { ::Holistic::SourceCode::Location.new(file_path: "my_app.rb") }

      let(:record_1) { spy }
      let(:record_2) { spy }

      let(:symbol_1) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol1", source_locations: [source_location], record: record_1) }
      let(:symbol_2) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol2", source_locations: [source_location], record: record_2) }

      before do
        application.symbols.index(symbol_1)
        application.symbols.index(symbol_2)
      end

      it "deletes symbols from the file index" do
        expect(application.symbols.list_symbols_in_file("my_app.rb")).to eql([symbol_1, symbol_2])

        application.symbols.delete_symbols_in_file("my_app.rb")

        expect(application.symbols.list_symbols_in_file("my_app.rb")).to eql([])
      end

      it "deletes symbols from the identifier index" do
        expect(application.symbols.find("::MySymbol1")).to eql(symbol_1)
        expect(application.symbols.find("::MySymbol2")).to eql(symbol_2)

        application.symbols.delete_symbols_in_file("my_app.rb")

        expect(application.symbols.find("::MySymbol1")).to be_nil
        expect(application.symbols.find("::MySymbol2")).to be_nil
      end

      it "calls the delete method on the symbol" do
        expect(record_1).to receive(:delete).with("my_app.rb")
        expect(record_2).to receive(:delete).with("my_app.rb")

        application.symbols.delete_symbols_in_file("my_app.rb")
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
      matches = application.symbols.search("Application").matches

      expect(matches[0].document).to have_attributes(
        identifier: "::MyApplication",
        text: "::MyApplication"
      )
    end

    it "does not find type inference results" do
      matches = application.symbols.search("").matches

      identifiers = matches.map { _1.document.identifier }

      expect(identifiers).to match_array([
        "::MyApplication",
        "::MyApplication::MyController",
        "::MyApplication::MyController#index"
      ])
    end

    # TODO: find references? find method declarations? find lambda declarations?
    # This should be optimized for the "I know what I'm looking for" mode, and not the exploration mode.
  end
end
