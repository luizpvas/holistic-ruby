# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Resolve do
  include ::Support::SnippetParser

  context "when solving method call to local class method" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyModule
        extend self

        def method_1
          method_2()
        end

        def method_2
          nil
        end
      end
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("method_2")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyModule.method_2")
    end
  end
end
