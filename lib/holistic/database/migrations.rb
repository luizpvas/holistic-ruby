# frozen_string_literal: true

module Holistic::Database::Migrations
  Run = ->(database) do
    # scope parent-children relation
    database.define_relation(name: :children, inverse_of: :parent)

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
