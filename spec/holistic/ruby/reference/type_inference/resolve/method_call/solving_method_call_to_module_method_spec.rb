# frozen_string_literal: true

describe ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued do
  include ::Support::SnippetParser

  context "when calling a module method defined with `self.method_name`" do
    let(:application) do
      parse_snippet <<~RUBY
      module Calculator
        def self.sum(a, b)
          a + b
        end
      end

      Calculator.sum(1, 2)
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Calculator.sum(1, 2)")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::Calculator.sum")
    end
  end

  context "when calling a module method with `extend self`" do
    let(:application) do
      parse_snippet <<~RUBY
      module Calculator
        extend self

        def sum(a, b)
          a + b
        end
      end

      Calculator.sum(1, 2)
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Calculator.sum(1, 2)")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::Calculator.sum")
    end
  end
end
