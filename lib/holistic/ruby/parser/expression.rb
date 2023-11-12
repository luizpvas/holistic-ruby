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
  class Expression
    Format = ->(node) do
      case node
      when ::SyntaxTree::VarRef then Format.(node.child_nodes[0])
      when ::SyntaxTree::VarField then Format.(node.child_nodes[0])
      when ::SyntaxTree::ConstRef then Format.(node.child_nodes[0])
      when ::SyntaxTree::Const  then node.value
      when ::SyntaxTree::ConstPathRef then Format.(node.child_nodes[0]) + "::" + Format.(node.child_nodes[1])
      when ::SyntaxTree::TopConstRef then "::" + Format.(node.child_nodes[0])
      when ::SyntaxTree::VCall then Format.(node.child_nodes[0])
      when ::SyntaxTree::Ident then node.value
      when ::SyntaxTree::Kw then node.value
      when ::SyntaxTree::Period then "."
      when ::SyntaxTree::CallNode then node.child_nodes.map(&Format).join
      when ::SyntaxTree::ArgParen then "(" + Format.(node.child_nodes[0]) + ")"
      when ::SyntaxTree::ArgBlock then "&" + Format.(node.child_nodes[0])

      # ARef represents the syntax of `data[:request]`
      # child_nodes[0] is the vcall for data
      # child_nodes[1] is an args with, usually, one item in it.
      when ::SyntaxTree::ARef then Format.(node.child_nodes[0]) + "[" + Format.(node.child_nodes[1]) + "]"

      when ::SyntaxTree::Paren then node.child_nodes.map(&Format)
      when ::SyntaxTree::LParen then "("
      when ::SyntaxTree::RParen then ")"
      when ::SyntaxTree::HashLiteral then "{" + node.child_nodes[1..].map(&Format).join(", ")  + "}"
      when ::SyntaxTree::BareAssocHash then node.child_nodes.map(&Format).join(", ")
      when ::SyntaxTree::ArrayLiteral then "[" + node.child_nodes[1..].map(&Format).join(", ") + "]"
      when ::SyntaxTree::Assoc then Format.(node.child_nodes[0]) + " " + Format.(node.child_nodes[1])
      when ::SyntaxTree::Label then node.value + ":"
      when ::SyntaxTree::Args then node.child_nodes.map(&Format).join(", ")
      when ::SyntaxTree::Int then node.value
      when ::SyntaxTree::StringLiteral then node.quote + node.parts[0].value + node.quote
      when ::SyntaxTree::SymbolLiteral then ":" + Format.(node.child_nodes[0])
      when ::SyntaxTree::Statements then raise ::ArgumentError
      when nil then ""
      else pp(node); raise "unknown node type #{node.class}"
      end
    end

    class InvalidExpression
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def valid? = false
    end

    def self.build_from_syntax_tree_node(node)
      self.new Format.(node)
    rescue ArgumentError
      InvalidExpression.new node.to_s
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

    def valid?
      true
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

    RemoveParensAndArguments = ->(method_call) do
      # if the method call start with "(" it means the syntax looked something like "foo.(10)"
      return "call" if method_call.start_with?("(")

      method_call.gsub(/\(.*\)/, "")
    end

    def namespaces
      return [] if starts_with_lower_case_letter?

      chain
        .reject(&StartsWithLowerCase)
        .reject(&IsSeparator)
    end

    def methods
      chain
        .select(&StartsWithLowerCase)
        .map(&RemoveParensAndArguments)
    end

    private

    def chain
      @chain ||= value.split(/(:|\.)/).compact_blank
    end

    def starts_with_lower_case_letter?
      StartsWithLowerCase.(value)
    end
  end
end
