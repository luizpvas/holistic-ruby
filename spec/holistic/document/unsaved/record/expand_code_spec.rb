# frozen_string_literal: true

describe ::Holistic::Document::Unsaved::Record do
  include ::Support::Document::ApplyChange

  describe "#expand_code" do
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
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 1, column: 1)

      token = document.expand_code(cursor)

      expect(token).to eql("")
    end

    it "returns identifier name if token is under variable" do
      # the dot after "my_application"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 2, column: 32)

      token = document.expand_code(cursor)

      expect(token).to eql("my_application.")
    end

    it "returns namespace name if token is under namespace" do
      # the second double-colon after "my_application"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 3, column: 21)

      token = document.expand_code(cursor)

      expect(token).to eql("MyLib::Payments::")
    end

    it "returns the chain call with identifeirs" do
      # the dot after "my_thing_2"
      cursor = ::Holistic::Document::Cursor.new(file_path: "example.rb", line: 4, column: 26)

      token = document.expand_code(cursor)

      expect(token).to eql("my_thing_1.my_thing_2.")
    end
  end
end
