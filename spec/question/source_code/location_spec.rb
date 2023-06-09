# frozen_string_literal: true

describe ::Question::SourceCode::Location do
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
end
