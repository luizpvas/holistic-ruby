# frozen_string_literal: true

describe ::Question::Ruby::Constant::Reference do
  let(:reference) do
    described_class.new(name: "MyClass", namespace: ::Question::Ruby::Constant::Namespace::GLOBAL)
  end

  it "has a name" do
    expect(reference.name).to eql("MyClass")
  end

  it "has a namespace" do
    expect(reference.namespace).to eql(::Question::Ruby::Constant::Namespace::GLOBAL)
  end
end