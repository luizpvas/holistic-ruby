# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when calling class methods defined in a `Data.define`" do
    let(:application) do
      parse_snippet <<~RUBY
      Status = ::Data.define(:value) do
        def self.ready
          new(value: "ready")
        end
      end

      Status.ready
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Status.ready")

      expect(reference.has_one(:referenced_scope).attr(:fully_qualified_name)).to eql("::Status.ready")
    end
  end
end
