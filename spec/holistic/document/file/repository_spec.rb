# frozen_string_literal: true

describe ::Holistic::Document::File::Repository do
  describe "#store" do
    context "when file does not exist in the repository" do
      it "stores a file indexed by the path" do
        repository = described_class.new

        file = ::Holistic::Document::File::Record.new(path: "/my_app/file.rb", adapter: ::Holistic::Document::File::Adapter::Memory)

        expect(repository.all.size).to be(0)

        repository.store(file)

        expect(repository.all.size).to be(1)
      end
    end

    context "when file already exists" do
      it "updates the existing record" do
        repository = described_class.new

        file_1 = ::Holistic::Document::File::Record.new(path: "/my_app/file.rb", adapter: ::Holistic::Document::File::Adapter::Memory)
        file_2 = ::Holistic::Document::File::Record.new(path: "/my_app/file.rb", adapter: ::Holistic::Document::File::Adapter::Memory)

        expect(repository.all.size).to be(0)

        repository.store(file_1)
        repository.store(file_2)

        expect(repository.all.size).to be(1)
      end
    end
  end

  describe "#find" do
    context "when file exists" do
      it "returns the file" do
        repository = described_class.new

        file = ::Holistic::Document::File::Record.new(path: "/my_app/file.rb", adapter: ::Holistic::Document::File::Adapter::Memory)

        repository.store(file)

        expect(repository.find("/my_app/file.rb")).to be(file)
      end
    end

    context "when file does not exist" do
      it "returns nil" do
        repository = described_class.new

        expect(repository.find("/non_existing_file.rb")).to be_nil
      end
    end
  end

  describe "#delete" do
    it "deletes a file from the repository" do
      repository = described_class.new

      file = ::Holistic::Document::File::Record.new(path: "/my_app/file.rb", adapter: ::Holistic::Document::File::Adapter::Memory)

      repository.store(file)
      repository.delete("/my_app/file.rb")

      expect(repository.all.size).to be(0)
    end
  end
end
