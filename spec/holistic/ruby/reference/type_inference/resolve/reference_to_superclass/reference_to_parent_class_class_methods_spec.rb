# frozen_string_literal: true

describe ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued do
  include ::Support::SnippetParser

  context "when calling instance methods defined in the parent class from the child class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Parent
        def self.parent_method
        end
      end

      class Child < Parent
        def self.child_method
          parent_method
        end
      end
      RUBY
    end

    it "resolves the method call reference" do
      parent_method_call = application.references.find_by_code_content("parent_method")

      expect(parent_method_call.referenced_scope.fully_qualified_name).to eql("::Parent.parent_method")
    end
  end

  context "when calling class methods defined in the grandparent class from the child class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Grandparent
        def self.grandparent_method
        end
      end

      class Parent < Grandparent; end

      class Child < Parent
        def self.child_method
          grandparent_method
        end
      end
      RUBY
    end

    it "resolves the method call reference" do
      parent_method_call = application.references.find_by_code_content("grandparent_method")

      expect(parent_method_call.referenced_scope.fully_qualified_name).to eql("::Grandparent.grandparent_method")
    end
  end

  context "when calling class methods on the child class referencing the scope name" do
    let(:application) do
      parse_snippet <<~RUBY
      class Parent
        def self.parent_method
        end
      end

      class Child < Parent; end

      Child.parent_method
      RUBY
    end

    it "resolves the method call reference" do
      parent_method_call = application.references.find_by_code_content("Child.parent_method")

      expect(parent_method_call.referenced_scope.fully_qualified_name).to eql("::Parent.parent_method")
    end
  end
end
