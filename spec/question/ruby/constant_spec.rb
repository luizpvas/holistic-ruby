# frozen_string_literal: true

describe ::Question::Ruby::Constant do
  describe "::Reference" do
    it "has a reference to a name and namespace" do
      reference = described_class::Reference.new(name: "Foo", namespace: described_class::Namespace::GLOBAL)

      expect(reference.name).to eq("Foo")
      expect(reference.namespace).to eq(described_class::Namespace::GLOBAL)
    end
  end

  describe "::Namespace" do
    context "::GLOBAL" do
      it "is a constant" do
        global = described_class::Namespace::GLOBAL

        expect(global).to be_a(::Object)
        expect(global.global?).to be(true)
      end
    end
  end

  describe "::Lookup" do
    
  end
end
