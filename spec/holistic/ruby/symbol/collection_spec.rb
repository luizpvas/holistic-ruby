# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Collection do
  include ::Support::SnippetParser

  describe "#index" do
    context "when symbol does not have source locations" do
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", locations: []) }

      it "stores the symbol in the identifier index" do
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
      end
    end

    context "when symbol has one source location" do
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }
      let(:locations) { [::Holistic::Document::Location.beginning_of_file("my_symbol.rb")] }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", locations:) }

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
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

      let(:locations) do
        [
          ::Holistic::Document::Location.beginning_of_file("my_symbol_1.rb"),
          ::Holistic::Document::Location.beginning_of_file("my_symbol_2.rb"),
        ]
      end

      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", locations:) }

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
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }
      let(:location) { ::Holistic::Document::Location.beginning_of_file("my_symbol_1.rb") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", locations: [location]) }

      it "does nothing" do
        application.symbols.index(symbol)
        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
        expect(application.symbols.list_symbols_in_file("my_symbol_1.rb").to_a).to eql([symbol])
      end
    end

    context "when indexing the same symbol multiple times with extra source locations" do
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }
      let(:location_1) { ::Holistic::Document::Location.beginning_of_file("my_symbol_1.rb") }
      let(:location_2) { ::Holistic::Document::Location.beginning_of_file("my_symbol_2.rb") }
      let(:symbol) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol", locations: [location_1]) }

      it "does nothing" do
        application.symbols.index(symbol)

        symbol.locations << location_2

        application.symbols.index(symbol)

        expect(application.symbols.find("::MySymbol")).to eql(symbol)
        expect(application.symbols.list_symbols_in_file("my_symbol_1.rb").to_a).to eql([symbol])
        expect(application.symbols.list_symbols_in_file("my_symbol_2.rb").to_a).to eql([symbol])
      end
    end
  end

  describe "#find_by_cursor" do
    let(:symbols) { described_class.new(application: nil) }

    let(:symbol) do
      ::Holistic::Ruby::Symbol::Record.new(
        identifier: "::MySymbol",
        locations: [
          ::Holistic::Document::Location.new(
            file_path: "app.rb",
            start_line: 5,
            start_column: 5,
            end_line: 5,
            end_column: 20
          )
        ]
      )
    end

    before { symbols.index(symbol) }

    context "when cursor is within symbol boundaries" do
      it "returns the symbol" do
        cursor = ::Holistic::Document::Cursor.new("app.rb", 5, 6)

        symbol_found = symbols.find_by_cursor(cursor)

        expect(symbol_found).to eql(symbol)
      end
    end

    context "when the cursor is not contained by any symbol" do
      it "returns nil" do
        cursor = ::Holistic::Document::Cursor.new("app.rb", 5, 21)

        symbol_found = symbols.find_by_cursor(cursor)

        expect(symbol_found).to be_nil
      end
    end
  end

  describe "#delete_symbols_in_file" do
    context "when file is not indexed" do
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

      it "does nothing" do
        expect(application.symbols.delete_symbols_in_file("non_existing.rb").to_a).to eql([])
      end
    end

    context "when file has symbols" do
      let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

      let(:location) { ::Holistic::Document::Location.beginning_of_file("my_app.rb") }

      let(:record_1) { spy }
      let(:record_2) { spy }

      let(:symbol_1) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol1", locations: [location], record: record_1) }
      let(:symbol_2) { ::Holistic::Ruby::Symbol::Record.new(identifier: "::MySymbol2", locations: [location], record: record_2) }

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
end
