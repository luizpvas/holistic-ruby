# frozen_string_literal: true

module Question::Ruby::Constant
  module Namespace
    GLOBAL = ::Object.new.tap do |singleton|
      def singleton.global? = true
    end

    Module = ::Struct.new(:parent, :name, keyword_init: true) do
      def global? = false
    end

    Class = ::Struct.new(:parent, :name, keyword_init: true) do
      def global? = false
    end

    ClassWithInheritance = ::Struct.new(:parent, :name, :superclass, keyword_init: true) do
      def global? = false
    end
  end
end
