# frozen_string_literal: true

describe ::Holistic::Document::File::Store do
  context "when file does not exist in the repository" do
    let(:database)   { ::Holistic::Database::Table.new }

    it "stores the file in the database" do
      expect(database.all.size).to be(0)

      file_path = "/my_app/file.rb"
      file = described_class.call(database:, file_path:)

      expect(file.path).to eql(file_path)
      expect(database.all.size).to be(1)
    end
  end

  context "when file already exists in the repository" do
    let(:database)   { ::Holistic::Database::Table.new }

    it "returns the existing file" do
      file_path = "/my_app/file.rb"

      file_from_1st_call = described_class.call(database:, file_path:)
      file_from_2nd_call = described_class.call(database:, file_path:)

      expect(file_from_1st_call).to be(file_from_2nd_call)

      expect(database.all.size).to be(1)
    end
  end
end
