# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::ListClassMethods do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      class Parent
        def self.parent_method
        end

        def self.overriden_method
        end
      end

      class Child < Parent
        def self.child_method
        end

        def self.overriden_method
        end
      end
    end
    RUBY
  end

  it "lists methods defined in the child and parent class minus overriden methods" do
    class_methods = described_class.call(scope: application.scopes.find("::MyApp::Child"))

    expect(
      class_methods.map { _1.fully_qualified_name }
    ).to match_array([
      "::MyApp::Child.new",
      "::MyApp::Child.child_method",
      "::MyApp::Parent.parent_method",
      "::MyApp::Child.overriden_method",
    ])
  end
end