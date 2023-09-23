# frozen_string_literal: true

describe ::Holistic::Document::Unsaved::Record do
  include ::Support::Document::ApplyChange

  describe "#has_unsaved_changes?" do
    it "returns true if the document has unsaved changes" do
      document = described_class.new(path: "/example.rb", content: ::String.new("content"))

      expect(document.has_unsaved_changes?).to be(false)

      insert_text_on_document(document:, text: "a", line: 0, column: 0)

      expect(document.has_unsaved_changes?).to be(true)

      expect(::File).to receive(:read).and_return("acontent")
      document.mark_as_saved!

      expect(document.has_unsaved_changes?).to be(false)
    end
  end
end
