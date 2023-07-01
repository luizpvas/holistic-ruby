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
    expect(application.symbols.find("::MyClass").record).to have_attributes(
      itself: be_a(::Holistic::Ruby::Namespace::Record)
    )

    expect(application.symbols.find("::MyClass#self.my_class_method").record).to have_attributes(
      itself: be_a(::Holistic::Ruby::Namespace::Record),
      name: "self.my_class_method"
    )

    expect(application.symbols.find("::MyClass#my_method").record).to have_attributes(
      itself: be_a(::Holistic::Ruby::Namespace::Record),
      name: "my_method"
    )

    expect(application.symbols.find("::MyClass#my_private_method").record).to have_attributes(
      itself: be_a(::Holistic::Ruby::Namespace::Record),
      name: "my_private_method"
    )
  end
end