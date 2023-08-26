# frozen_string_literal: true

describe ::Holistic::Document::File::Register do
  context "when file does not exist in the repository" do
    it "stores the file in the repository" do
      repository = ::Holistic::Document::File::Repository.new
      file_path = "/my_app/file.rb"

      expect(repository.all.size).to be(0)

      file = described_class.call(repository:, file_path:)

      expect(file.path).to eql(file_path)

      expect(repository.all.size).to be(1)
    end
  end

  context "when file already exists in the repository" do
    it "returns the existing file" do
      repository = ::Holistic::Document::File::Repository.new
      file_path = "/my_app/file.rb"

      file_from_1st_call = described_class.call(repository:, file_path:)
      file_from_2nd_call = described_class.call(repository:, file_path:)

      expect(file_from_1st_call).to be(file_from_2nd_call)

      expect(repository.all.size).to be(1)
    end
  end
end
