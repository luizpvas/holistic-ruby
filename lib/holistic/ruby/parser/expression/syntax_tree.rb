# frozen_string_literal: true

module Holistic::Ruby::Parser::Expression
  module SyntaxTree
    Format = ->(node) do
      case node
      when ::SyntaxTree::VarRef then Format.(node.child_nodes[0])
      when ::SyntaxTree::VarField then Format.(node.child_nodes[0])

      # IVar stands for instance variable. The value of the node looks something like "@items"
      when ::SyntaxTree::IVar then node.value

      # ARef represents the syntax of `data[:request]`
      # child_nodes[0] is the vcall for data
      # child_nodes[1] is an args with, usually, one item in it.
      when ::SyntaxTree::ARef then Format.(node.child_nodes[0]) + "[" + Format.(node.child_nodes[1]) + "]"

      when ::SyntaxTree::ConstRef then Format.(node.child_nodes[0])
      when ::SyntaxTree::Const  then node.value
      when ::SyntaxTree::ConstPathRef then Format.(node.child_nodes[0]) + "::" + Format.(node.child_nodes[1])
      when ::SyntaxTree::TopConstRef then "::" + Format.(node.child_nodes[0])

      when ::SyntaxTree::VCall then Format.(node.child_nodes[0])
      when ::SyntaxTree::Ident then node.value
      when ::SyntaxTree::Kw then node.value
      when ::SyntaxTree::Period then "."
      when ::SyntaxTree::Op then node.value
      when ::SyntaxTree::Binary then Format.(node.left) + " || " + Format.(node.right)

      when ::SyntaxTree::CallNode then node.child_nodes.map(&Format).join
      when ::SyntaxTree::ArgParen then "(" + Format.(node.child_nodes[0]) + ")"
      when ::SyntaxTree::ArgBlock then "&" + Format.(node.child_nodes[0])
      when ::SyntaxTree::ArgStar then "*" + Format.(node.child_nodes[0])
      when ::SyntaxTree::Paren then node.child_nodes.map(&Format)
      when ::SyntaxTree::LParen then "("
      when ::SyntaxTree::RParen then ")"

      # MethodAddBlock is the syntax for something like "items.filter { |item| item.active? }"
      when ::SyntaxTree::MethodAddBlock then Format.(node.child_nodes[0]) + " <BLOCK>"

      when ::SyntaxTree::HashLiteral then "{" + node.child_nodes[1..].map(&Format).join(", ")  + "}"
      when ::SyntaxTree::BareAssocHash then node.child_nodes.map(&Format).join(", ")
      when ::SyntaxTree::ArrayLiteral then "[" + node.child_nodes[1..].map(&Format).join(", ") + "]"
      when ::SyntaxTree::Assoc then Format.(node.child_nodes[0]) + " " + Format.(node.child_nodes[1])
      when ::SyntaxTree::Label then node.value + ":"
      when ::SyntaxTree::Args then node.child_nodes.map(&Format).join(", ")

      when ::SyntaxTree::StringLiteral then node.quote + node.child_nodes.map(&Format).join + node.quote
      when ::SyntaxTree::TStringContent then node.value
      when ::SyntaxTree::StringEmbExpr then "\#{" + Format.(node.child_nodes[0].child_nodes[0]) + "}"

      when ::SyntaxTree::Int then node.value
      when ::SyntaxTree::SymbolLiteral then ":" + Format.(node.child_nodes[0])
      when ::SyntaxTree::RegexpLiteral then node.beginning + node.parts.map(&:value).join + node.ending
      when ::SyntaxTree::RangeNode then Format.(node.left) + Format.(node.operator) + Format.(node.right)
      when ::SyntaxTree::QSymbols then node.beginning.value + node.elements.map(&Format).join(" ") + "]"

      when ::SyntaxTree::Statements then raise ::ArgumentError
      when nil then ""
      else ::Holistic.logger.info(node.location); raise "unknown node type #{node.class}"
      end
    end

    def self.build(node)
      Valid.new Format.(node)
    rescue ArgumentError
      Invalid.new node.to_s
    end
  end
end
