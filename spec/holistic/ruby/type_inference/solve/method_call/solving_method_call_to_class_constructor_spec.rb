# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when instantiating a class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Example
        def initialize; end
      end

      Example.new
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Example.new")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Example#initialize"
      )
    end
  end
end
