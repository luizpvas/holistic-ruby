# frozen_string_literal: true

describe ::Holistic::Extensions::Ruby::Stdlib do
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
    
    it "stores a scope for the `new` class method" do
      scope = application.scopes.find("::Example.new")

      expect(scope).to be_a(::Holistic::Ruby::Scope::Record)
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("Example.new")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::Example#initialize")
    end
  end
end
