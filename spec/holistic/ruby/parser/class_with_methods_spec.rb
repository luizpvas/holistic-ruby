# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    class MyClass
      def self.my_class_method; end

      def my_method; end

      private

      def my_private_method; end
    end
    RUBY
  end

  it "parses the code" do
    expect(
      application.scopes.find("::MyClass").attr(:name)
    ).to eql("MyClass")

    expect(
      application.scopes.find("::MyClass.my_class_method").attr(:name)
    ).to eql("my_class_method")

    expect(
      application.scopes.find("::MyClass#my_method").attr(:name)
    ).to eql("my_method")

    expect(
      application.scopes.find("::MyClass#my_private_method").attr(:name)
    ).to eql("my_private_method")
  end
end