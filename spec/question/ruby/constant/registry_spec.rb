# frozen_string_literal: true

describe ::Question::Ruby::Constant::Registry do
  describe "#initialize" do
    subject(:registry) { described_class.new }

    it "starts out with the global namespace" do
      expect(registry.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
    end
  end

  describe "#open_module" do
    subject(:registry) { described_class.new }

    it "updates the current namespace inside the block" do
      registry.open_module("MyModule") do
        expect(registry.namespace.name).to eql("MyModule")
        expect(registry.namespace.parent).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
      end

      expect(registry.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
    end
  end

  describe "#add_reference" do
    context "when the namespace is global" do
      subject(:registry) { described_class.new }

      it "adds the reference in global namespace" do
        registry.add_reference!("MyReference")

        expect(registry.references.size).to eql(1)
        expect(registry.references.first.name).to eql("MyReference")
        expect(registry.references.first.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
      end
    end

    context "when namespace is NOT global" do
      subject(:registry) { described_class.new }

      it "adds a reference in the nested namespace" do
        registry.open_module("MyModule") do
          registry.add_reference!("MyReference")
        end

        expect(registry.references.size).to eql(1)
        expect(registry.references.first.name).to eql("MyReference")
        expect(registry.references.first.namespace.name).to eql("MyModule")
      end
    end
  end
end
