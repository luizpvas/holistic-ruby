# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when calling a method in the same class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Calculator
        def sum(a, b)
          a + b
        end

        def plus(a, b)
          sum(a, b)
        end
      end
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("sum")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Calculator#sum"
      )
    end
  end
end
