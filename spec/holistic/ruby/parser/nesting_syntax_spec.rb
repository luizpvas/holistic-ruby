# frozen_string_literal: true

describe ::Holistic::Ruby::Parser::NestingSyntax do
  describe "#constant?" do
    context "when value is a constant" do
      it "returns true" do
        expect(described_class.new("Foo")).to be_a_constant
        expect(described_class.new(["Foo", "Bar"])).to be_a_constant
      end
    end

    context "when value is an identifier" do
      it "returns false" do
        expect(described_class.new("foo")).not_to be_a_constant
        expect(described_class.new(["Foo", "bar"])).not_to be_a_constant
      end
    end
  end
end
