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
        expect { registry.close! }.to raise_error("Cannot close global namespace")
      end
    end
  end

  describe "#add_reference" do
    context "when the namespace is global" do
      subject(:registry) { described_class.new }

      it "adds the reference in global namespace" do
        registry.add_reference! do |namespace|
          ::Question::Ruby::Constant::Reference.new(namespace:, name: "MyReference")
        end

        expect(registry.references.size).to eql(1)
        expect(registry.references.first.name).to eql("MyReference")
        expect(registry.references.first.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
      end
    end

    context "when namespace is NOT global" do
      subject(:registry) { described_class.new }

      before do
        registry.open! do |namespace|
          ::Question::Ruby::Constant::Namespace::Module.new(parent_namespace: namespace, name: "MyNamespace")
        end
      end

      it "adds a reference in the nested namespace" do
        registry.add_reference! do |namespace|
          ::Question::Ruby::Constant::Reference.new(namespace:, name: "MyReference")
        end

        registry.close!

        expect(registry.references.size).to eql(1)
        expect(registry.references.first.name).to eql("MyReference")
        expect(registry.references.first.namespace.name).to eql("MyNamespace")
      end
    end
  end
end
