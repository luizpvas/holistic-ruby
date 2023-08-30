# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Store
    extend self

    def call(database:, parent:, kind:, name:, location:)
      fully_qualified_name = build_fully_qualified_name(parent:, kind:, name:)

      scope = database.find(fully_qualified_name)

      if scope.nil?
        record = Record.new(fully_qualified_name, { fully_qualified_name:, name:, kind:, locations: Location::Collection.new(name) })

        scope = database.store(fully_qualified_name, record)
      end

      scope.locations << location

      database.connect(source: parent, target: scope, name: :children, inverse_of: :parent)
      database.connect(source: location.declaration.file, target: scope, name: :defines_scopes, inverse_of: :scope_defined_in_file)

      scope
    end

    private

    def build_fully_qualified_name(parent:, kind:, name:)
      parent_fully_qualified_name =
        case parent.kind
        when Kind::ROOT then ""
        else parent.fully_qualified_name
        end

      separator =
        case kind
        when Kind::INSTANCE_METHOD then "#"
        when Kind::CLASS_METHOD    then "."
        else "::"
        end

      "#{parent_fully_qualified_name}#{separator}#{name}"
    end
  end
end