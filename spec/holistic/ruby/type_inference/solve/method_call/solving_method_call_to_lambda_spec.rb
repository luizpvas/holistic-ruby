# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when calling a module method" do
    let(:application) do
      parse_snippet <<~RUBY
      Sum = ->(a, b) { a + b }

      Sum.call(1, 2)
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Sum.call")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Sum"
      )
    end
  end
end
