# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Node
    BuildNestingSyntax = ->(node) do
      nesting_syntax = NestingSyntax.new

      append = ->(node) do
        case node
        when ::SyntaxTree::ConstRef     then nesting_syntax << node.child_nodes[0].value
        when ::SyntaxTree::VarField     then nesting_syntax << node.child_nodes.first.value
        when ::SyntaxTree::Const        then nesting_syntax << node.value
        when ::SyntaxTree::VCall        then append.(node.child_nodes.first)
        when ::SyntaxTree::Ident        then nesting_syntax << node.value
        when ::SyntaxTree::IVar         then nesting_syntax << node.value
        when ::SyntaxTree::Period       then nesting_syntax << "."
        when ::SyntaxTree::Paren        then append.(node.child_nodes[1])       # node.child_nodes[0] is ::SyntaxTree::LParen
        when ::SyntaxTree::ARef         then append.(node.child_nodes.first)    # not sure what to do here e.g. `ActiveRecord::Migration[7.0]`
        when ::SyntaxTree::CallNode     then node.child_nodes.each(&append)
        when ::SyntaxTree::IfOp         then nesting_syntax << "[conditional]"  # not sure what tod o here
        when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
        when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
        when ::SyntaxTree::Statements   then node.child_nodes.each(&append)
        when ::SyntaxTree::TopConstRef  then nesting_syntax.mark_as_root_scope! and node.child_nodes.each(&append)
        # else pp(original_node) and pp(Current.file.path) and raise "Unexpected node type: #{node.class}"
        end
      end

      append.(node)

      nesting_syntax
    end
  end
end
