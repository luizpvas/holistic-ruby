# frozen_string_literal: true

describe ::Holistic::Document::File::Repository do
  describe "#store" do
    context "when file does not exist in the repository" do
      let(:database)   { ::Holistic::Database::Table.new }
      let(:repository) { described_class.new(database:) }

      it "stores a file indexed by the path" do
        expect(database.all.size).to be(0)

        repository.store("/my_app/file.rb")

        expect(database.all.size).to be(1)
      end
    end

    context "when file already exists" do
      let(:database)   { ::Holistic::Database::Table.new }
      let(:repository) { described_class.new(database:) }

      it "updates the existing record" do
        expect(database.all.size).to be(0)

        repository.store("/my_app/file.rb")
        repository.store("/my_app/file.rb")

        expect(database.all.size).to be(1)
      end
    end
  end

  describe "#find" do
    context "when file exists" do
      let(:database)   { ::Holistic::Database::Table.new }
      let(:repository) { described_class.new(database:) }

      it "returns the file" do
        file = repository.store("/my_app/file.rb")

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
