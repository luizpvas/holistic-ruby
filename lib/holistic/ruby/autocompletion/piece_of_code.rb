# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  class PieceOfCode
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def suggester
      if empty?
        return Suggester::Everything.new(self)
      end

      if starts_with_lower_case_letter? || (looks_like_method_call? && !has_dot?)
        return Suggester::MethodsFromCurrentScope.new(self)
      end

      if has_dot?
        return Suggester::MethodsFromScope.new(self)
      end

      Suggester::Constants.new(self)
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
