# frozen_string_literal: true

describe ::Holistic::Document::Unsaved::Record do
  include ::Support::Document::ApplyChange

  describe "#has_unsaved_changes?" do
    it "returns true if the document has unsaved changes" do
      document = described_class.new(path: "/example.rb", content: ::String.new("content"))

      expect(document.has_unsaved_changes?).to be(false)

      insert_text_on_document(document:, text: "a", line: 0, column: 0)

      expect(document.has_unsaved_changes?).to be(true)

      document.mark_as_saved!

      expect(document.has_unsaved_changes?).to be(false)
    end
  end

  describe "#expand_token" do
    let(:content) do
      <<~RUBY
      module MyApp
        def something
          do_something(my_application.)
          MyLib::Payments::
          my_thing_1.my_thing_2.
        end
      end
      RUBY
    end

    let(:document) { described_class.new(path: "example.rb", content: content) }

    it "returns an empty string if there is no token under the cursor" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 1, column: 0)

      token = document.expand_token(cursor)

      expect(token).to eql("")
    end

    it "returns identifier name if token is under variable" do
      # the dot after "my_application"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 2, column: 31)

      token = document.expand_token(cursor)

      expect(token).to eql("my_application.")
    end

    it "returns namespace name if token is under namespace" do
      # the second double-colon after "my_application"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 3, column: 20)

      token = document.expand_token(cursor)

      expect(token).to eql("MyLib::Payments::")
    end

    it "returns the chain call with identifeirs" do
      # the dot after "my_thing_2"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 4, column: 25)

      token = document.expand_token(cursor)

      expect(token).to eql("my_thing_1.my_thing_2.")
    end
  end
end
