# frozen_string_literal: true

describe ::Holistic::Document::Unsaved::Record do
  include ::Support::Document::ApplyChange

  describe "#apply_change" do
    it "inserts the first character of a blank document" do
      document = described_class.new(path: "/example.rb", content: ::String.new(""))

      change = ::Holistic::Document::Unsaved::Change.new(
        range_length: 0,
        text: "a",
        start_line: 0,
        start_column: 0,
        end_line: 0,
        end_column: 0
      )

      document.apply_change(change)

      expect(document.content).to eql("a")
    end

    it "inserts the second character of a document" do
      document = described_class.new(path: "/example.rb", content: ::String.new(""))

      document.apply_change(
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 0,
          text: ::String.new("a"),
          start_line: 0,
          start_column: 0,
          end_line: 0,
          end_column: 0
        )
      )

      document.apply_change(
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 0,
          text: ::String.new("b"),
          start_line: 0,
          start_column: 1,
          end_line: 0,
          end_column: 1
        )
      )

      expect(document.content).to eql("ab")
    end

    it "inserts and deletes a character of a blank document" do
      document = described_class.new(path: "/example.rb", content: ::String.new(""))

      document.apply_change(
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 0,
          text: ::String.new("a"),
          start_line: 0,
          start_column: 0,
          end_line: 0,
          end_column: 0
        )
      )

      document.apply_change(
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 1,
          text: "",
          start_line: 0,
          start_column: 0,
          end_line: 0,
          end_column: 1
        )
      )

      expect(document.content).to eql("")
    end
  end
end
