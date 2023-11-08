# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Resolver::ClassMethod
  extend self

  def resolve(scope:, method_name:)
    scope.crawler.ancestors.each do |parent_scope|
      found = parent_scope.lexical_children.filter(&:class_method?).find { _1.name == method_name }

      return found if found
    end

    nil
  end
end
