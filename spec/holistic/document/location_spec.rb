# frozen_string_literal: true

describe ::Holistic::Document::Location do
  describe "#identifier" do
    it "formats the identifier based on the file path, lines and columns" do
      location = described_class.new(
        file_path: "my_app/example.rb",
        start_line: 1,
        start_column: 2,
        end_line: 3,
        end_column: 4
      )

      expect(location.identifier).to eql("my_app/example.rb[1,2,3,4]")
    end
  end

  describe "#contains?" do
    let(:range) do
      described_class.new(
        file_path: "app.rb",
        start_line: 5,
        start_column: 10,
        end_line: 5,
        end_column: 20
      )
    end

    let(:examples) do
      [
        # before the first character of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 10), expected: false },
        # after the last character of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 21), expected: false },
        # before the first line of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 4, 21), expected: false },
        # after the first line of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 6, 21), expected: false },
        # after the first character of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 11), expected: true },
        # before the last character of the range
        { cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 20), expected: true }
      ]
    end

    it "returns true if the cursor is within range's boundaries" do
      examples.each do |example|
        expect(range.contains?(example[:cursor])).to eql(example[:expected])
      end
    end
  end
end
