# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record < ::Holistic::Database::Node
    def fully_qualified_name = attr(:fully_qualified_name)
    def locations            = attr(:locations)
    def name                 = attr(:name)
    def kind                 = attr(:kind)

    def lexical_parent   = has_one(:lexical_parent)
    def lexical_children = has_many(:lexical_children)
    def referenced_by    = has_many(:referenced_by)

    def root?            = kind == Kind::ROOT
    def class?           = kind == Kind::CLASS
    def class_method?    = kind == Kind::CLASS_METHOD
    def instance_method? = kind == Kind::INSTANCE_METHOD
    def method?          = class_method? || instance_method?
  end
end
