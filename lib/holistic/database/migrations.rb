# frozen_string_literal: true

module Holistic::Database::Migrations
  Run = ->(database) do
    # scope lexical parent-children relation
    database.define_relation(name: :lexical_children, inverse_of: :lexical_parent)

    # scope inheritance and mixins
    database.define_relation(name: :ancestors, inverse_of: :descendants)

    # type inference conclusion
    database.define_relation(name: :referenced_scope, inverse_of: :referenced_by)

    # reference definition
    database.define_relation(name: :located_in_scope, inverse_of: :contains_many_references)

    # scope location in files
    database.define_relation(name: :defines_scopes, inverse_of: :scope_defined_in_file)

    # reference location in files
    database.define_relation(name: :defines_references, inverse_of: :reference_defined_in_file)
  end
end
