# frozen_string_literal: true

module Holistic::Ruby::Parser
  # Expression is not complete implementation of all ruby expressions.
  # The goal is to support constant resolution, method calls and literals.
  #
  # The reason we convert the SyntaxTree node to string and store the expression
  # as a string is because we need to support invalid syntax for autocompletion to work.
  # For example, if the user types "Foo::Bar::" would not parse correctly, but we can
  # understand that we're dealing with the constants "Foo" and "Bar" and we need to
  # suggest constants in that namespace.
  class Expression2
    Format = ->(node) do
      case node
      when ::SyntaxTree::VarRef then Format.(node.child_nodes[0])
      when ::SyntaxTree::Const  then node.value
      when ::SyntaxTree::ConstPathRef then Format.(node.child_nodes[0]) + "::" + Format.(node.child_nodes[1])
      when ::SyntaxTree::TopConstRef then "::" + Format.(node.child_nodes[0])
      when ::SyntaxTree::VCall then Format.(node.child_nodes[0])
      when ::SyntaxTree::Ident then node.value
      when ::SyntaxTree::Period then "."
      when ::SyntaxTree::CallNode then node.child_nodes.map(&Format).join
      when ::SyntaxTree::ArgParen then "(" + Format.(node.child_nodes[0]) + ")"
      when ::SyntaxTree::Args then node.child_nodes.map(&Format).join(", ")
      when ::SyntaxTree::Int then node.value
      when nil then ""
      else pp(node); pp(node.class); raise "unknown node type #{node.class}"
      end
    end

    def self.build_from_syntax_tree_node(node)
      self.new Format.(node)
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value
    end

    def each(&)
      namespaces.each(&)
    end

    def root_scope_resolution?
      value.start_with?("::")
    end

    # TODO: remove this method
    def constant?
      namespaces.any?
    end

    IsSeparator = ->(str) { str == ":" || str == "." }

    StartsWithLowerCase = ->(str) do
      return false if [".", ":", "@"].include? str[0]

      str[0] == str[0].downcase
    end

    def namespaces
      return [] if starts_with_lower_case_letter?

      value.split(/(:|\.)/)
        .compact_blank
        .reject(&StartsWithLowerCase)
        .reject(&IsSeparator)
    end

    def starts_with_lower_case_letter?
      StartsWithLowerCase.(value)
    end
  end
end
