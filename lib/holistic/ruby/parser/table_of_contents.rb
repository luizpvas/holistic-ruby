# frozen_string_literal: true

module Holistic::Ruby::Parser
  # TODO: move to an attibute of the scope
  class TableOfContents
    attr_reader :records

    def initialize
      @records = Hash.new { |hash, key| hash[key] = {} }
    end

    def register(scope:, name:, clue:)
      @records[scope.fully_qualified_name][name] ||= []
      @records[scope.fully_qualified_name][name] << clue
    end
  end
end