# frozen_string_literal: true

describe Holistic::Ruby::Namespace::Delete do
  context "when the namespace has a single source location" do
    let(:root_namespace) { ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }
    let(:source_location) { ::Holistic::SourceCode::Location.new(file_path: "dummy.rb") }
    let(:namespace) { ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", source_location:) }

    it "detaches the namespace from the parent" do
      expect(root_namespace.children).to eql([namespace])

      described_class.call(namespace:, file_path: "dummy.rb")

      expect(root_namespace.children).to eql([])
    end
  end

  context "when the namespace has multiple source locations" do
    let(:root_namespace) { ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }

    let(:source_location_1) { ::Holistic::SourceCode::Location.new(file_path: "dummy_1.rb") }
    let(:source_location_2) { ::Holistic::SourceCode::Location.new(file_path: "dummy_2.rb") }

    let(:namespace) do
      ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", source_location: source_location_1)
      ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", source_location: source_location_2)
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
    let(:root_namespace) { ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }
    let(:source_location) { ::Holistic::SourceCode::Location.new(file_path: "dummy.rb") }
    let(:namespace) { ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", source_location:) }

    it "raises an error" do
      expect {
        described_class.call(namespace:, file_path: "unrelated_file.rb")
      }.to raise_error(::ArgumentError, "Namespace is not defined in the file path")
    end
  end
end
