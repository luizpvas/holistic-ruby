# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Record do
  describe "#delete" do
    it "delegates to the record's #delete method" do
      record = double

      expect(record).to receive(:delete).with("example.rb")

      symbol = described_class.new(record:)

      symbol.delete("example.rb")
    end
  end
end
