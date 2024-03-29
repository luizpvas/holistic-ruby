# frozen_string_literal: true

module Holistic::EmbeddedAgent
  module Event
    Spec = ::Data.define(:required)

    FORMATS = {
      "register_constant" => Spec.new(
        required: %i[
          fully_qualified_lexical_parent
          name
          type
        ]
      ),
      "register_instance_method" => Spec.new(
        required: %i[
          fully_qualified_name
        ]
      ),
      "register_class_method" => Spec.new(
        required: %i[
          fully_qualified_name
        ]
      )
    }.freeze
  end
end
