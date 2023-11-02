# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Resolve do
  include ::Support::SnippetParser

  context "when methods defined in the included module" do
    let(:application) do
      parse_snippet <<~RUBY
      module Parent
        def parent_method
        end
      end

      class Child
        include Parent

        def child_method
          parent_method
        end
      end
      RUBY
    end

    it "resolves the method call reference" do
      reference = application.references.find_by_code_content("parent_method")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::Parent#parent_method")
    end
  end
end
