# frozen_string_literal: true

module Holistic::Ruby::Parser::Expression
  # Expression is not complete implementation of all ruby expressions.
  # The goal is to support constant resolution, method calls and literals.
  #
  # The reason we convert the SyntaxTree node to string and store the expression
  # as a string is because we need to support invalid syntax for autocompletion to work.
  # For example, if the user types "Foo::Bar::" would not parse correctly, but we can
  # understand that we're dealing with the constants "Foo" and "Bar" and we need to
  # suggest constants in that namespace.
  class Valid
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value
    end

    def each(&)
      namespaces.each(&)
    end

    def empty?
      value.empty?
    end

    def valid?
      true
    end

    def root_scope_resolution?
      value.start_with?("::")
    end

    IsSeparator = ->(str) { str == ":" || str == "." }

    StartsWithLowerCase = ->(str) do
      return false if [".", ":", "@"].include? str[0]

      str[0] == str[0].downcase
    end

    RemoveParensAndArguments = ->(method_call) do
      # if the method call start with "(" it means the syntax looked something like "foo.(10)"
      return "call" if method_call.start_with?("(")

      method_call.gsub(/\(.*\)/, "")
    end

    def namespaces
      return [] if starts_with_lower_case_letter?

      chain
        .reject(&StartsWithLowerCase)
        .reject(&IsSeparator)
    end

    def methods
      chain
        .select(&StartsWithLowerCase)
        .map(&RemoveParensAndArguments)
    end

    def last_subexpression
      @last_subexpression ||= chain.last.then { |last| IsSeparator.(last) ? "" : last }
    end

    def starts_with_lower_case_letter?
      StartsWithLowerCase.(value)
    end

    def looks_like_method_call?
      value.include?("(")
    end

    def has_dot?
      value.include?(".")
    end

    private

    def chain
      @chain ||= value.split(/(:|\.)/).compact_blank
    end
  end
end
