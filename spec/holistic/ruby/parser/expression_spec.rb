# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Parser::Expression do
  concerning :Helpers do
    def expression(value)
      described_class::Valid.new(value)
    end

    def assert_expression(value, formatted = nil)
      program = ::SyntaxTree.parse(value)
      node    = program.child_nodes.first.child_nodes.first
      expr    = described_class::SyntaxTree.build(node)

      expect(expr.value).to eql(formatted || value)
    end
  end

  describe "::SyntaxTree.build" do
    it "understands namespaces and method call chains" do
      assert_expression("Foo")
      assert_expression("Foo::Bar")
      assert_expression("Foo::Bar::Qux")
      assert_expression("Foo::Bar::Qux::Baz")
      assert_expression("::Foo")
      assert_expression("::Foo::Bar")
      assert_expression("described_class::Value")
      assert_expression("foo(10)")
      assert_expression("foo(10, 20)")
      assert_expression("data[:request].response.inspect")
      assert_expression("@relations[connection_name].to_a")
      assert_expression("@records[id]&.tap")
      assert_expression("@content[token_index].match?(/[a-zA-Z0-9_\.:]/)")
      assert_expression(
        "@listeners[event].lazy.filter_map { |callback| callback.call(params) }",
        "@listeners[event].lazy.filter_map <BLOCK>" 
      )
      assert_expression('data["params"].dig(*keys)')
      assert_expression('"string literal #{cursor.file_path}"')
      assert_expression("node.child_nodes[1..]")
      assert_expression("method_name_node || instance_node")
    end
  end

  describe "#root_scope_resolution?" do
    it "returns true for namespaces for ::, false otherwise" do
      expect(expression("::Foo").root_scope_resolution?).to be(true)
      expect(expression("Foo").root_scope_resolution?).to be(false)
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

  describe "#last_subexpression" do
    it "returns the last namespace or method call in the chain" do
      expect(expression("foo").last_subexpression).to eql("foo")
      expect(expression("foo.bar").last_subexpression).to eql("bar")
      expect(expression("Foo.bar").last_subexpression).to eql("bar")
      expect(expression("Foo.bar.").last_subexpression).to eql("")
      expect(expression("Foo").last_subexpression).to eql("Foo")
      expect(expression("Foo::Bar").last_subexpression).to eql("Bar")
      expect(expression("Foo::Bar::").last_subexpression).to eql("")
      expect(expression("::").last_subexpression).to eql("")
    end
  end
end
