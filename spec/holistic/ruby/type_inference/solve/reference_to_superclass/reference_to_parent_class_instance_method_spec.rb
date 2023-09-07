# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when calling methods defined in the parent class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Parent
        def parent_method
        end
      end

      class Child < Parent
        def child_method
          parent_method
        end
      end
      RUBY
    end

    it "solves the method call reference" do
      parent_method_call = application.references.find_by_code_content("parent_method")

      expect(parent_method_call.referenced_scope.fully_qualified_name).to eql("::Parent#parent_method")
    end
  end
end
