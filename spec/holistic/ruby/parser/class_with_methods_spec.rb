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
    expect(application.scopes.find_by_fully_qualified_name("::MyClass")).to have_attributes(
      itself: be_a(::Holistic::Ruby::Scope::Record)
    )

    expect(application.scopes.find_by_fully_qualified_name("::MyClass.my_class_method")).to have_attributes(
      itself: be_a(::Holistic::Ruby::Scope::Record),
      name: "my_class_method"
    )

    expect(application.scopes.find_by_fully_qualified_name("::MyClass#my_method")).to have_attributes(
      itself: be_a(::Holistic::Ruby::Scope::Record),
      name: "my_method"
    )

    expect(application.scopes.find_by_fully_qualified_name("::MyClass#my_private_method")).to have_attributes(
      itself: be_a(::Holistic::Ruby::Scope::Record),
      name: "my_private_method"
    )
  end
end