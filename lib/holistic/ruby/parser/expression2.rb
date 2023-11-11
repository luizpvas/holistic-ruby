# frozen_string_literal: true

module Holistic::Ruby::Parser
  class Expression2
    def self.build_from_syntax_tree_node(node)
      format = ->(node) do
        case node
        when ::SyntaxTree::VarRef then format.(node.child_nodes[0])
        when ::SyntaxTree::Const  then node.value
        when ::SyntaxTree::ConstPathRef then format.(node.child_nodes[0]) + "::" + format.(node.child_nodes[1])
        when ::SyntaxTree::TopConstRef then "::" + format.(node.child_nodes[0])
        when ::SyntaxTree::VCall then format.(node.child_nodes[0])
        when ::SyntaxTree::Ident then node.value
        else binding.irb
        end
      end

      self.new format.(node)
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
