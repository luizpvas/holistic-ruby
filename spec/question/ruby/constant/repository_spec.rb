# frozen_string_literal: true

describe ::Question::Ruby::Constant::Repository do
  let(:root) { ::Question::Ruby::Constant::Namespace.new(kind: :root, name: "::", parent: nil) }

  describe "#initialize" do
    subject(:repository) { described_class.new(root:) }

    it "starts in the root namespace" do
      expect(repository.namespace).to be(root)
    end
  end

  describe "#open_module" do
    subject(:repository) { described_class.new(root:) }

    it "updates the current namespace inside the block" do
      source_location = ::Question::Ruby::SourceLocation.new

      repository.open_module(name: "MyModule", source_location:) do
        expect(repository.namespace.name).to eql("MyModule")
        expect(repository.namespace.parent).to be(root)
      end

      expect(repository.namespace).to be(root)
    end
  end

  describe "#add_reference" do
    context "when the namespace is root" do
      subject(:repository) { described_class.new(root:) }

      it "adds the reference in root namespace" do
        repository.add_reference!("MyReference")

        expect(repository.references.size).to eql(1)
        expect(repository.references.first.name).to eql("MyReference")
        expect(repository.references.first.namespace).to be(root)
      end
    end

    context "when namespace is NOT root" do
      subject(:repository) { described_class.new(root:) }

      it "adds a reference in the nested namespace" do
        source_location = ::Question::Ruby::SourceLocation.new

        repository.open_module(name: "MyModule", source_location:) do
          repository.add_reference!("MyReference")
        end

        expect(repository.references.size).to eql(1)
        expect(repository.references.first.name).to eql("MyReference")
        expect(repository.references.first.namespace.name).to eql("MyModule")
      end
    end
  end
end
