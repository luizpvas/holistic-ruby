# frozen_string_literal: true

describe ::Question::Ruby::Constant::Reference do
  describe ".new" do
    let(:reference) do
      described_class.new(name: "MyClass", resolution: ["MyModule"])
    end

    it "has a name and resolution" do
      expect(reference).to have_attributes(
        name: "MyClass",
        resolution: ["MyModule"]
      )
    end
  end
end
