# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Unregister
    extend self

    def call(repository:, reference:)
      repository.delete(reference.identifier)
    end
  end
end
