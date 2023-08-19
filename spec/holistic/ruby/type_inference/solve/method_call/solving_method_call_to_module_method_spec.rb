# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

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
      reference = application.references.find_by_code_content("Calculator.sum")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Calculator.sum"
      )
    end
  end
end
