# frozen_string_literal: true

describe Question::Ruby::Namespace::Delete do
  context "when the namespace has a single source location" do
    let(:root_namespace) { ::Question::Ruby::Namespace::Record.new(kind: :root, name: "::", parent: nil) }
    let(:source_location) { ::Question::SourceCode::Location.new(file_path: "dummy.rb") }
    let(:namespace) { root_namespace.nest(kind: :module, name: "Dummy", source_location:) }

    it "detaches the namespace from the parent" do
      expect(root_namespace.children).to eql([namespace])

      described_class.call(namespace:, file_path: "dummy.rb")

      expect(root_namespace.children).to eql([])
    end
  end

  context "when the namespace has multiple source locations" do
    let(:root_namespace) { ::Question::Ruby::Namespace::Record.new(kind: :root, name: "::", parent: nil) }

    let(:source_location_1) { ::Question::SourceCode::Location.new(file_path: "dummy_1.rb") }
    let(:source_location_2) { ::Question::SourceCode::Location.new(file_path: "dummy_2.rb") }

    let(:namespace) do
      root_namespace.nest(kind: :module, name: "Dummy", source_location: source_location_1)
      root_namespace.nest(kind: :module, name: "Dummy", source_location: source_location_2)
    end

    it "removes the source location" do
      expect(namespace.source_locations).to eql([source_location_1, source_location_2])

      described_class.call(namespace:, file_path: "dummy_1.rb")

      expect(namespace.source_locations).to eql([source_location_2])
    end

    it "detaches from the parent only when deleted from the last source location" do
      expect(root_namespace.children).to eql([namespace])

      described_class.call(namespace:, file_path: "dummy_1.rb")

      expect(root_namespace.children).to eql([namespace])

      described_class.call(namespace:, file_path: "dummy_2.rb")

      expect(root_namespace.children).to eql([])
    end
  end

  context "when the namespace is not defined in the file path" do
    let(:root_namespace) { ::Question::Ruby::Namespace::Record.new(kind: :root, name: "::", parent: nil) }
    let(:source_location) { ::Question::SourceCode::Location.new(file_path: "dummy.rb") }
    let(:namespace) { root_namespace.nest(kind: :module, name: "Dummy", source_location:) }

    it "raises an error" do
      expect {
        described_class.call(namespace:, file_path: "unrelated_file.rb")
      }.to raise_error(::ArgumentError, "Namespace is not defined in the file path")
    end
  end
end
