# frozen_string_literal: true

describe ::Holistic::Document::Location do
  concerning :Helpers do
    def build_file(path)
      ::Holistic::Document::File::Record.new(path:)
    end
  end

  describe "#identifier" do
    it "formats the identifier based on the file path, lines and columns" do
      location = described_class.new(
        file: build_file("my_app/example.rb"),
        start_line: 1,
        start_column: 2,
        end_line: 3,
        end_column: 4
      )

      expect(location.identifier).to eql("my_app/example.rb[1,2,3,4]")
    end
  end

  describe "#contains?" do
    let(:examples) do
      [
        # before the first character of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 10),
          expected: false
        },
        # after the last character of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 21),
          expected: false
        },
        # before the first line of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 4, 21),
          expected: false
        },
        # after the first line of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 6, 21),
          expected: false
        },
        # after the first character of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 11),
          expected: true
        },
        # before the last character of the range
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 5, end_column: 20),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 20),
          expected: true
        },
        # after the first column of location spanning multiple lines
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 6, end_column: 5),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 11),
          expected: true
        },
        # before the last column of location spanning multiple lines
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 6, end_column: 5),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 6, 4),
          expected: true
        },
        # in the middle of location spanning multiple lines
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 7, end_column: 5),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 6, 999),
          expected: true
        },
        # before the first column of location spanning multiple lines
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 7, end_column: 5),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 5, 9),
          expected: false
        },
        # after the last column of location spanning multiple lines
        {
          location: described_class.new(file: build_file("app.rb"), start_line: 5, start_column: 10, end_line: 7, end_column: 5),
          cursor: ::Holistic::Document::Cursor.new("app.rb", 7, 6),
          expected: false
        }
      ]
    end

    it "returns true if the cursor is within range's boundaries" do
      examples.each do |example|
        location, cursor, result = example[:location], example[:cursor], example[:expected]

        expect(location.contains?(cursor)).to eql(result)
      end
    end
  end
end
