# frozen_string_literal: true

describe ::Holistic::Document::File::Repository do
  describe "#find" do
    context "when file exists" do
      let(:database)   { ::Holistic::Database::Table.new }
      let(:repository) { described_class.new(database:) }

      it "returns the file" do
        file = ::Holistic::Document::File::Register.call(database:, file_path: "/my_app/file.rb")

        expect(repository.find("/my_app/file.rb")).to be(file)
      end
    end

    context "when file does not exist" do
      let(:database)   { ::Holistic::Database::Table.new }
      let(:repository) { described_class.new(database:) }

      it "returns nil" do
        expect(repository.find("/non_existing_file.rb")).to be_nil
      end
    end
  end
end
