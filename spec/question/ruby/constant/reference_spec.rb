# frozen_string_literal: true

describe ::Question::Ruby::Constant::Reference do
  describe ".new" do
    let(:namespace) do
      ::Question::Ruby::Namespace::Record.new(kind: :module, name: "MyModule", parent: nil)
    end

    let(:reference) do
      described_class.new(name: "MyClass", namespace:)
    end

    it "has a name and namespace" do
      expect(reference).to have_attributes(
        name: "MyClass",
        namespace:
      )
    end
  end
end
