# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record < ::Holistic::Database::Node
    def fully_qualified_name = attr(:fully_qualified_name)
    def locations            = attr(:locations)
    def name                 = attr(:name)
    def kind                 = attr(:kind)

    def lexical_parent   = has_one(:lexical_parent)
    def lexical_children = has_many(:lexical_children)
    def ancestors        = has_many(:ancestors)
    def descendants      = has_many(:descendants)
    def referenced_by    = has_many(:referenced_by)

    def root?            = kind == Kind::ROOT
    def class?           = kind == Kind::CLASS
    def class_method?    = kind == Kind::CLASS_METHOD
    def instance_method? = kind == Kind::INSTANCE_METHOD
    def method?          = class_method? || instance_method?

    def sibling_methods
      case kind
      when Kind::CLASS_METHOD
        query_sibling_class_methods = ->(scope) do
          class_methods = scope.lexical_children.filter(&:class_method?)

          scope.ancestors.flat_map { |ancestor| query_sibling_class_methods.(ancestor) }.concat(class_methods)
        end

        query_sibling_class_methods.(lexical_parent)
      when Kind::INSTANCE_METHOD
        nil
      else
        raise "unexpected scope kind"
      end
    end
  end
end
