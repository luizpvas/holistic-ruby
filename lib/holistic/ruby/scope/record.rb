# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record < ::Holistic::Database::Node
    def fully_qualified_name = attr(:fully_qualified_name)
    def locations            = attr(:locations)
    def name                 = attr(:name)
    def kind                 = attr(:kind)

    def parent        = has_one(:parent)
    def children      = has_many(:children)
    def referenced_by = has_many(:referenced_by)
  end
end
