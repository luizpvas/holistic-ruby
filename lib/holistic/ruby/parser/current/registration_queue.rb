# frozen_string_literal: true

class Holistic::Ruby::Parser::Current
  class RegistrationQueue
    attr_reader :application

    def initialize(application:)
      @application = application
      @symbols = []
    end

    def register(symbol)
      raise ::ArgumentError, "#{symbol.inspect} must be a Symbol" unless symbol.is_a?(::Holistic::Ruby::Symbol::Record)

      @symbols << symbol
    end

    def process
      @symbols.each do |symbol|
        update_search_index(symbol)
      end

      @symbols.each do |symbol|
        solve_type_inference(symbol)
      end

      @symbols.clear
    end

    private

    def update_search_index(symbol)
      application.symbols.index(symbol)
    end
  
    def solve_type_inference(symbol)
      return unless symbol.record.is_a?(::Holistic::Ruby::TypeInference::Reference)

      ::Holistic::Ruby::TypeInference::Solve.call(
        application:,
        reference: symbol.record
      )
    end
  end
end
