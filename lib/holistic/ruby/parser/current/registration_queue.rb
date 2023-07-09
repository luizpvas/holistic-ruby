# frozen_string_literal: true

class Holistic::Ruby::Parser::Current
  class RegistrationQueue
    attr_reader :application

    def initialize(application:)
      @application = application
      @references = []
    end

    def register(reference)
      @references << reference
    end

    def process
      @references.each do |reference|
        ::Holistic::Ruby::TypeInference::Solve.call(application:, reference:)
      end

      @references.clear
    end
  end
end
