# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record < ::Holistic::Database::Node
    def locations = attr(:locations)
  end
end
