# frozen_string_literal: true

describe ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued do
  include ::Support::SnippetParser

  context "when calling class methods defined in `Struct.new`" do
    let(:application) do
      parse_snippet <<~RUBY
      Status = ::Struct.new(:value) do
        def self.ready
          new("ready")
        end
      end

      Status.ready
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Status.ready")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::Status.ready")
    end
  end
end
