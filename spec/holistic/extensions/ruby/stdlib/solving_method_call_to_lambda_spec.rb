# frozen_string_literal: true

describe ::Holistic::Extensions::Ruby::Stdlib do
  include ::Support::SnippetParser

  context "when calling a lambda with the :call method" do
    let(:application) do
      parse_snippet <<~RUBY
      Sum = ->(a, b) { a + b }

      Sum.call(1, 2)
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Sum.call")

      expect(reference.has_one(:referenced_scope).fully_qualified_name).to eql("::Sum.call")
    end
  end

  context "when currying a lambda with the :curry method" do
    let(:application) do
      parse_snippet <<~RUBY
      Sum = ->(a, b) { a + b }

      Sum.curry(1).call(2)
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Sum.curry")

      expect(reference.has_one(:referenced_scope).fully_qualified_name).to eql("::Sum.curry")
    end
  end
end
