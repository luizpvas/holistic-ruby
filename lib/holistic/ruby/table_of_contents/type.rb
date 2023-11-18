# frozen_string_literal: true

module Holistic::Ruby::TableOfContents
  module Type
    class Unknown
    end

    class Instance
      attr_reader :fully_qualified_name

      def initialize(fully_qualified_name)
        @fully_qualified_name = fully_qualified_name
      end
    end

    class Scope
    end

    class HashWithSchema
    end
  end
end
