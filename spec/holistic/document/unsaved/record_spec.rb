# frozen_string_literal: true

describe ::Holistic::Document::Unsaved::Record do
  concerning :Helpers do
    def apply_change_to_document!(document)
      change =
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 1,
          text: "a",
          start_line: 0,
          start_column: 0,
          end_line: 0,
          end_column: 0
        )
      
      document.apply_change(change)
    end
  end

  describe "#has_unsaved_changes?" do
    it "returns true if the document has unsaved changes" do
      document = described_class.new(path: "/example.rb", content: ::String.new("content"))

      expect(document.has_unsaved_changes?).to be(false)

      apply_change_to_document!(document)

      expect(document.has_unsaved_changes?).to be(true)

      document.mark_as_saved!

      expect(document.has_unsaved_changes?).to be(false)
    end
  end
end
