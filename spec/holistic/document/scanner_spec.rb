# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Document::Scanner do
  describe "#find_index" do
    context "when document is empty and cursor is at (0, 0)" do
      it "finds the correct index" do
        scanner = described_class.new("")
        
        index = scanner.find_index(0, 0)

        expect(index).to eql(0)
      end
    end

    context "when cursor is on the first line" do
      let(:scanner) do
        described_class.new <<~RUBY
        abcdef
        ghijkl
        mnopqr
        RUBY
      end

      it "finds the correct index" do
        index = scanner.find_index(0, 5)

        expect(index).to eql(5)
      end
    end

    context "when cursor is on the second line" do
      let(:scanner) do
        described_class.new <<~RUBY
        abcdef
        ghijkl
        mnopqr
        RUBY
      end

      it "finds the correct index" do
        index = scanner.find_index(1, 5)

        expect(index).to eql(12)
      end
    end

    context "when cursor is on the last character of the last line" do
      let(:scanner) do
        described_class.new <<~RUBY
        abcdef
        ghijkl
        mnopqr
        RUBY
      end

      it "finds the correct index" do
        index = scanner.find_index(2, 5)

        expect(index).to eql(19)
      end
    end
  end
end
