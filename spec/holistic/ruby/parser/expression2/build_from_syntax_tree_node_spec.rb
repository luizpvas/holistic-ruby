# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Parser::Expression2 do
  concerning :Helpers do
    def assert_expression(value)
      program = ::SyntaxTree.parse(value)
      node = program.child_nodes.first.child_nodes.first

      expression = described_class.build_from_syntax_tree_node(node)

      expect(expression.value).to eql(value)
    end
  end

  describe "#build_from_syntax_tree_node" do
    it "understands namespaces" do
      assert_expression("Foo")
      assert_expression("Foo::Bar")
      assert_expression("Foo::Bar::Qux")
      assert_expression("Foo::Bar::Qux::Baz")
      assert_expression("::Foo")
      assert_expression("::Foo::Bar")
      assert_expression("described_class::Value")
    end
  end
end
