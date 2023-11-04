# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Kind
    extend self

    ROOT            = :root
    MODULE          = :module
    CLASS           = :class
    INSTANCE_METHOD = :instance_method
    CLASS_METHOD    = :class_method
    LAMBDA          = :lambda

    Subkind = {
      ROOT            => Kind::Root,
      MODULE          => Kind::Module,
      CLASS           => Kind::Class,
      INSTANCE_METHOD => Kind::InstanceMethod,
      CLASS_METHOD    => Kind::ClassMethod,
      LAMBDA          => Kind::Lambda
    }.freeze

    def build(scope)
      Subkind.fetch(scope.kind).new(scope)
    end
  end
end
