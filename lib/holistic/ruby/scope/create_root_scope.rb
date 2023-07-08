# frozen_string_literal: true

module Holistic::Ruby::Scope
  module CreateRootScope
    extend self

    def call
      Record.new(kind: Kind::ROOT, name: "::", parent: nil)
    end
  end
end
