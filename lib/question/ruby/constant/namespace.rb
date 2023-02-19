# frozen_string_literal: true

module Question::Ruby::Constant
  module Namespace
    GLOBAL = ::Object.new.tap do |singleton|
      def singleton.global? = true
    end

    Module = ::Struct.new(:parent, :name, :source_locations, keyword_init: true) do
      def global? = false
    end

    Class = ::Struct.new(:parent, :name, :source_locations, keyword_init: true) do
      def global? = false
    end

    # Does it make sense to have this here? Should it just be `Class` with a different parent?
    ClassWithInheritance = ::Struct.new(:parent, :name, :superclass, :source_locations, keyword_init: true) do
      def global? = false
    end
  end
end
