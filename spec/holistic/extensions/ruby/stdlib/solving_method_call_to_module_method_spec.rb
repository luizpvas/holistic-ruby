# frozen_string_literal: true

describe ::Holistic::Extensions::Ruby::Stdlib do
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
      reference = application.references.find_by_code_content("Calculator.sum")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Calculator#self.sum"
      )
    end
  end
end