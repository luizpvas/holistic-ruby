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

    # TODO: rename to something more descriptive.
    def subkind
      @subkind ||= Kind.build(self)
    end

    def inspect
      "<#{self.class.name} kind=#{kind} fully_qualified_name=#{fully_qualified_name}>"
    end

    delegate :closest_namespace, to: :subkind
    delegate :visible_to?, to: :subkind
  end
end
