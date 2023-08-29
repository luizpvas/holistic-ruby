# frozen_string_literal: true

module Holistic::Ruby::Scope::Lexical
  extend self

  def descendant?(child:, parent:)
    child_parent = child.parent

    child_parent.present? && (child_parent == parent || descendant?(child: child_parent, parent:))
  end
end
