# frozen_string_literal: true

module Holistic::Ruby::Autocompletion::Suggester
  class Everything
    def initialize(piece_of_code)
      @piece_of_code = piece_of_code
    end

    def suggest(scope:)
      raise "todo"
    end
  end

  class Constants
    def initialize(piece_of_code)
      @piece_of_code = piece_of_code
    end

    def suggest(scope:)
      raise "todo"
    end
  end

  class MethodsFromCurrentScope
    def initialize(piece_of_code)
      @piece_of_code = piece_of_code
    end

    def suggest(scope:)
      raise "todo"
    end
  end

  class MethodsFromScope
    def initialize(piece_of_code)
      @piece_of_code = piece_of_code
    end

    def suggest(scope:)
      raise "todo"
    end
  end
end
