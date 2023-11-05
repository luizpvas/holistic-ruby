# frozen_string_literal: true

module Holistic::Ruby::Autocompletion::Suggester
  class Namespaces
    def initialize(piece_of_code:, scope:)
      @piece_of_code = piece_of_code
      @scope = scope
    end

    def suggest
      raise "todo"
    end
  end

  class MethodsFromCurrentScope
    def initialize(piece_of_code:, scope:)
      @piece_of_code = piece_of_code
      @scope = scope
    end

    def suggest
      raise "todo"
    end
  end

  class MethodsFromScope
    def initialize(piece_of_code:, scope:)
      @piece_of_code = piece_of_code
      @scope = scope
    end

    def suggest
      raise "todo"
    end
  end
end
