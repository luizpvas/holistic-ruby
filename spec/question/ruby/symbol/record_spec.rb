# frozen_string_literal: true

describe ::Question::Ruby::Symbol::Record do
  describe "#destroy" do
    it "delegates to the record's #destroy method" do
      record = double

      expect(record).to receive(:destroy)

      symbol = described_class.new(record:)

      symbol.destroy
    end
  end
end
