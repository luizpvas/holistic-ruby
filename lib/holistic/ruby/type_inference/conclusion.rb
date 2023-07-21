# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  STATUS_PENDING = :pending
  STATUS_DONE    = :done

  Conclusion = ::Struct.new(
    :status,
    :dependency_identifier,
    keyword_init: true
  ) do
    def self.pending
      new(status: STATUS_PENDING, dependency_identifier: nil)
    end

    def self.unresolved
      new(status: STATUS_DONE, dependency_identifier: nil)
    end

    def self.done(dependency_identifier)
      new(status: STATUS_DONE, dependency_identifier:)
    end
  end
end