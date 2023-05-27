# frozen_string_literal: true

describe ::Question::Ruby::Source::Location do
  subject(:source_location) do
    described_class.new(
      file_path: "/home/user/my_project/lib/my_project.rb",
      start_line: 10,
      end_line: 15
    )
  end

  it "has a file path" do
    expect(source_location.file_path).to eql("/home/user/my_project/lib/my_project.rb")
  end

  it "has a start line" do
    expect(source_location.start_line).to eql(10)
  end

  it "has an end line" do
    expect(source_location.end_line).to eql(15)
  end
end
