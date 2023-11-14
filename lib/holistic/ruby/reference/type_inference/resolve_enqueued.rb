# frozen_string_literal: true

module Holistic::Ruby::Reference
  module TypeInference::ResolveEnqueued
    extend self

    def call(application:)
      retry_later = []

      until application.type_inference_resolving_queue.empty?
        reference = application.type_inference_resolving_queue.pop

        case resolve(application:, reference:)
        when :resolved then nil
        when :unresolved then retry_later << reference
        end
      end

      retry_later.each do |reference|
        application.type_inference_resolving_queue.push(reference)
      end
    end

    private

    def resolve(application:, reference:)
      bag_of_clues = ::Holistic::Ruby::TypeInference::BagOfClues.new(reference.clues)
      resolver = ::Holistic::Ruby::TypeInference::Resolver.new(application:)
      referenced_scope = resolver.resolve(scope: reference.located_in_scope, bag_of_clues:)

      return :unresolved if !referenced_scope

      reference.relation(:referenced_scope).add!(referenced_scope)

      bag_of_clues.find(::Holistic::Ruby::TypeInference::Clue::ReferenceToSuperclass)&.then do |reference_to_superclass_clue|
        referenced_scope.relation(:descendants).add!(reference_to_superclass_clue.subclass_scope)
      end

      :resolved
    end
  end
end
