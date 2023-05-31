# frozen_string_literal: true

describe ::Question::Ruby::Symbol::InvertedIndex do
  describe "#index" do
    let(:application) { ::Question::Ruby::Application.new(name: "Example", root_directory: "example") }

    it "starts out empty" do
      inverted_index = application.symbol_inverted_index

      expect(inverted_index.data).to be_empty
    end

    it "adds the first symbol" do
      inverted_index = application.symbol_inverted_index

      symbol = ::Question::Ruby::Symbol::Record.new

      inverted_index.index("file.rb", symbol)

      expect(inverted_index.data).to eql({ "file.rb" => [symbol] })
    end

    it "adds the second, third and subsequent symbols" do
      inverted_index = application.symbol_inverted_index

      symbol_1 = ::Question::Ruby::Symbol::Record.new
      symbol_2 = ::Question::Ruby::Symbol::Record.new
      symbol_3 = ::Question::Ruby::Symbol::Record.new

      inverted_index.index("file.rb", symbol_1)
      inverted_index.index("file.rb", symbol_2)
      inverted_index.index("file.rb", symbol_3)

      expect(inverted_index.data).to eql({ "file.rb" => [symbol_1, symbol_2, symbol_3] })
    end
  end
end
