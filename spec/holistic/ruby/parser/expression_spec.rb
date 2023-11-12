# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Parser::Expression do
  concerning :Helpers do
    def expression(value)
      program = ::SyntaxTree.parse(value)
      node = program.child_nodes.first.child_nodes.first

      described_class.build_from_syntax_tree_node(node)
    end

    def assert_expression(value)
      expr = expression value

      expect(expr.value).to eql(value)
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
      assert_expression("foo(10)")
      assert_expression("foo(10, 20)")
    end
  end

  describe "#root_scope_resolution?" do
    it "returns true for namespaces for ::, false otherwise" do
      expect(expression("::Foo").root_scope_resolution?).to be(true)
      expect(expression("Foo").root_scope_resolution?).to be(false)
    end
  end

  describe "#constant?" do
    it "returns true for constants, false otherwise" do
      expect(expression("::Foo").constant?).to be(true)
      expect(expression("Foo").constant?).to be(true)
      expect(expression("Foo::Bar").constant?).to be(true)
      expect(expression("Foo.bar").constant?).to be(true)
      expect(expression("foo").constant?).to be(false)
      expect(expression("class_name.constantize").constant?).to be(false)
    end
  end

  describe "#namespaces" do
    it "returns the namespaces" do
      expect(expression("::Foo").namespaces).to eql(["Foo"])
      expect(expression("::Foo::Bar").namespaces).to eql(["Foo", "Bar"])
      expect(expression("Foo::Bar").namespaces).to eql(["Foo", "Bar"])
      expect(expression("Foo.bar").namespaces).to eql(["Foo"])
      expect(expression("Foo.bar(10)").namespaces).to eql(["Foo"])
      expect(expression("Foo.()").namespaces).to eql(["Foo"])
      expect(expression("foo").namespaces).to eql([])
      expect(expression("foo.bar").namespaces).to eql([])
    end
  end

  describe "#methods" do
    it "returns the method chain" do
      expect(expression("foo").methods).to eql(["foo"])
      expect(expression("foo.bar").methods).to eql(["foo", "bar"])
      expect(expression("foo.bar.qux").methods).to eql(["foo", "bar", "qux"])
      expect(expression("foo(10).bar").methods).to eql(["foo", "bar"])
      expect(expression("Foo.bar").methods).to eql(["bar"])
      expect(expression("Foo::Bar.qux").methods).to eql(["qux"])
      expect(expression("Foo::Bar.qux.quz").methods).to eql(["qux", "quz"])
      expect(expression("Foo::Bar").methods).to eql([])
      expect(expression("Foo").methods).to eql([])
      expect(expression("Foo.(10)").methods).to eql(["call"])
    end
  end
end
