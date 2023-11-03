# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  class PieceOfCode
    attr_reader :value

    def initialize(value)
      @value = value
    end
  
    def kind
      return :suggest_everything_from_current_scope if suggest_everything_from_current_scope?
      return :suggest_methods_from_current_scope if suggest_methods_from_current_scope?
      return :suggest_methods_from_scope if suggest_methods_from_scope?
      return :suggest_namespaces if suggest_namespaces?

      :unknown
    end

    def suggest_everything_from_current_scope?
      empty?
    end

    def suggest_methods_from_current_scope?
      !empty? && starts_with_lower_case_letter? || (looks_like_method_call? && !has_dot?)
    end

    def suggest_methods_from_scope?
      !empty? && !suggest_methods_from_current_scope? && has_dot?
    end

    def suggest_namespaces?
      !empty? && !starts_with_lower_case_letter? && !has_dot?
    end

    def root_scope?
      @value.start_with? "::"
    end

    def to_s
      @value
    end

    IsSeparator = ->(str) { str == ":" || str == "." }

    def namespaces
      return [] if starts_with_lower_case_letter?

      @value.split(/(:|\.)/)
        .compact_blank.tap { _1.pop }
        .reject(&IsSeparator)
    end

    def word_to_autocomplete
      return "" if empty?

      @value.split(/(:|\.)/).compact_blank.pop.then do |value|
        IsSeparator[value] ? "" : value
      end
    end

    private

    def empty?
      @value.strip.empty?
    end

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
