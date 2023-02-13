# frozen_string_literal: true

describe ::Question::Ruby::Constant::Registry do
  describe "#initialize" do
    subject(:registry) { described_class.new }

    it "starts out with the global namespace" do
      expect(registry.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
    end
  end

  describe "#open!" do
    subject(:registry) { described_class.new }

    it "updates the current namespace with the result from the block" do
      registry.open! do |namespace|
        ::Question::Ruby::Constant::Namespace::Module.new(parent_namespace: namespace, name: "MyNamespace")
      end

      expect(registry.namespace.name).to eql("MyNamespace")
      expect(registry.namespace.parent_namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
    end
  end

  describe "#close!" do
    context "when the current namespace is NOT global" do
      subject(:registry) { described_class.new }

      it "restores the previous namespace" do
        expect(registry.namespace.global?).to be(true)

        registry.open! do |namespace|
          ::Question::Ruby::Constant::Namespace::Module.new(parent_namespace: namespace, name: "MyNamespace")
        end

        expect(registry.namespace.global?).to be(false)

        registry.close!

        expect(registry.namespace.global?).to be(true)
      end
    end

    context "when the current namespace is global" do
      subject(:registry) { described_class.new }

      it "raises an error" do
        expect { registry.close! }.to raise_error(described_class::CannotCloseGlobalNamespaceError)
      end
    end
  end
end
