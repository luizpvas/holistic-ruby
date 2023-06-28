# frozen_string_literal: true

describe ::Holistic::Ruby::Namespace::Delete do
  context "when the namespace has a single source location" do
    let(:root_namespace) { ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }
    let(:location) { ::Holistic::Document::Location.beginning_of_file("dummy.rb") }
    let(:namespace) { ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", location:) }

    it "detaches the namespace from the parent" do
      expect(root_namespace.children).to eql([namespace])

      described_class.call(namespace:, file_path: "dummy.rb")

      expect(root_namespace.children).to eql([])
    end
  end

  context "when the namespace has multiple source locations" do
    let(:root_namespace) { ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }

    let(:location_1) { ::Holistic::Document::Location.beginning_of_file("dummy_1.rb") }
    let(:location_2) { ::Holistic::Document::Location.beginning_of_file("dummy_2.rb") }

    let(:namespace) do
      ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", location: location_1)
      ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", location: location_2)
    end

    it "removes the source location" do
      expect(namespace.locations).to eql([location_1, location_2])

      described_class.call(namespace:, file_path: "dummy_1.rb")

      expect(namespace.locations).to eql([location_2])
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
    let(:location) { ::Holistic::Document::Location.beginning_of_file("dummy.rb") }
    let(:namespace) { ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: root_namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Dummy", location:) }

    it "raises an error" do
      expect {
        described_class.call(namespace:, file_path: "unrelated_file.rb")
      }.to raise_error(::ArgumentError, "Namespace is not defined in the file path")
    end
  end
end
