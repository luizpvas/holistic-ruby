# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Delete do
  context "when the scope has a single source location" do
    let(:root_scope) { ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil) }
    let(:location) { ::Holistic::Document::Location.beginning_of_file("dummy.rb") }
    let(:scope) { ::Holistic::Ruby::Scope::RegisterChildScope.call(parent: root_scope, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Dummy", location:) }

    it "detaches the scope from the parent" do
      expect(root_scope.children).to eql([scope])

      described_class.call(scope:, file_path: "dummy.rb")

      expect(root_scope.children).to eql([])
    end
  end

  context "when the scope has multiple source locations" do
    let(:root_scope) { ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil) }

    let(:location_1) { ::Holistic::Document::Location.beginning_of_file("dummy_1.rb") }
    let(:location_2) { ::Holistic::Document::Location.beginning_of_file("dummy_2.rb") }

    let(:scope) do
      ::Holistic::Ruby::Scope::RegisterChildScope.call(parent: root_scope, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Dummy", location: location_1)
      ::Holistic::Ruby::Scope::RegisterChildScope.call(parent: root_scope, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Dummy", location: location_2)
    end

    it "removes the source location" do
      expect(scope.locations).to eql([location_1, location_2])

      described_class.call(scope:, file_path: "dummy_1.rb")

      expect(scope.locations).to eql([location_2])
    end

    it "detaches from the parent only when deleted from the last source location" do
      expect(root_scope.children).to eql([scope])

      described_class.call(scope:, file_path: "dummy_1.rb")

      expect(root_scope.children).to eql([scope])

      described_class.call(scope:, file_path: "dummy_2.rb")

      expect(root_scope.children).to eql([])
    end
  end

  context "when the scope is not defined in the file path" do
    let(:root_scope) { ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil) }
    let(:location) { ::Holistic::Document::Location.beginning_of_file("dummy.rb") }
    let(:scope) { ::Holistic::Ruby::Scope::RegisterChildScope.call(parent: root_scope, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Dummy", location:) }

    it "raises an error" do
      expect {
        described_class.call(scope:, file_path: "unrelated_file.rb")
      }.to raise_error(::ArgumentError, "Scope is not defined in the file path")
    end
  end
end
