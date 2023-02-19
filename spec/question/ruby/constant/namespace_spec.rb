# frozen_string_literal: true

describe ::Question::Ruby::Constant::Namespace do
  describe "::GLOBAL" do
    it "is a constant" do
      expect(described_class::GLOBAL).to be_an(::Object)
      expect(described_class::GLOBAL.object_id).to eql(described_class::GLOBAL.object_id)
    end

    it "is global" do
      expect(described_class::GLOBAL.global?).to be(true)
    end
  end

  describe "::Module" do
    let(:my_module) do
      described_class::Module.new(parent: described_class::GLOBAL, name: "MyModule", source_locations: [])
    end

    it "has a parent namespace" do
      expect(my_module.parent).to eql(described_class::GLOBAL)
    end

    it "has a name" do
      expect(my_module.name).to eql("MyModule")
    end

    it "has many source locations" do

    end

    it "is not global" do
      expect(my_module.global?).to be(false)
    end
  end

  describe "::Class" do
    let(:my_class) do
      described_class::Class.new(parent: described_class::GLOBAL, name: "MyClass")
    end

    it "has a parent namespace" do
      expect(my_class.parent).to eql(described_class::GLOBAL)
    end

    it "has a name" do
      expect(my_class.name).to eql("MyClass")
    end

    it "is not global" do
      expect(my_class.global?).to be(false)
    end
  end

  describe "::ClassWithInheritance" do
    let(:superclass) do
      ::Question::Ruby::Constant::Reference.new(name: "Superclass", namespace: described_class::GLOBAL)
    end

    let(:my_class_with_inheritance) do
      described_class::ClassWithInheritance.new(
        parent: described_class::GLOBAL,
        name: "MyClassWithInheritance",
        superclass:
      )
    end

    it "has a parent namespace" do
      expect(my_class_with_inheritance.parent).to eql(described_class::GLOBAL)
    end

    it "has a name" do
      expect(my_class_with_inheritance.name).to eql("MyClassWithInheritance")
    end

    it "has a superclass" do
      expect(my_class_with_inheritance.superclass).to eql(superclass)
    end

    it "is not global" do
      expect(my_class_with_inheritance.global?).to be(false)
    end
  end
end
