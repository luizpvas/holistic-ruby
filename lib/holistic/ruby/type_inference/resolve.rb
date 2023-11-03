# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Resolve
    extend self

    def call(application:, reference:)
      bag_of_clues = BagOfClues.new(reference.clues)
      resolver = Resolver.new(application:)
      referenced_scope = resolver.resolve(scope: reference.located_in_scope, bag_of_clues:)

      if referenced_scope
        reference.relation(:referenced_scope).add!(referenced_scope)

        # NOTE: should this be an event that is handled by stdlib? I guess inheritance support with dedicated syntax
        # is part of the language core, so it makes sense being here. Let me think about this for a bit.
        reference.find_clue(Clue::ReferenceToSuperclass)&.then do |reference_to_superclass_clue|
          referenced_scope.relation(:descendants).add!(reference_to_superclass_clue.subclass_scope)
        end
      end
    end
  end
end
