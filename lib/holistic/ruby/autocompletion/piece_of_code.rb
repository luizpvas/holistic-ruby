# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  class PieceOfCode
    attr_reader :value

    def initialize(value)
      @value = value
    end
  
    def kind
      return :suggest_methods_from_current_scope if suggest_methods_from_current_scope?
      return :suggest_methods_from_scope if suggest_methods_from_scope?
      return :suggest_namespaces if suggest_namespaces?

      :unknown
    end

    def suggest_methods_from_current_scope?
      starts_with_lower_case_letter? || (looks_like_method_call? && !has_dot?)
    end

    def suggest_methods_from_scope?
      !suggest_methods_from_current_scope? && has_dot?
    end

    def suggest_namespaces?
      !starts_with_lower_case_letter? && !has_dot?
    end

    def root_scope?
      @value.start_with? "::"
    end

    def to_s
      @value
    end

    private

    def starts_with_lower_case_letter?
      return false if [".", ":", "@"].include? @value[0]

      @value[0] == @value[0].downcase
    end

    def looks_like_method_call?
      @value.include? "("
    end

    def has_dot?
      @value.include? "."
    end
  end
end
