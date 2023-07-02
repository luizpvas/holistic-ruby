# frozen_string_literal: true

class Holistic::Ruby::Parser::Current
  # Parsing is done in four phases.
  #
  # 1. Register scopes, contants, declarations, lambdas, etc. as they are encountered in source code.
  # 2. Update symbol index.
  # 3. Run type inference algorithm.
  # 4. Update dependency graph.
  #
  # This class is responsible to handle the steps after the first one. If you're interested in the first phase,
  # take a look at the `Visitor` class.
  #
  # At this point, the source of truth is good. We have scopes, constants, declarations, lambdas, etc. in their specialized
  # types related to one another.
  #
  # ## When to accumulate and when to process?
  #
  # In the boot process (Holistic::Cli::Start) we need to parse all files in the project *and then* process them. This is because
  # dependency graph and type inference needs all definitions available. We can't process them as we go.
  #
  # After the initial boot, we have a similar situation for file changes, but this time at a smaller scale. The visitor registers
  # symbols as it goes and then we can process the queue for that particular file. This is because the rest of the project remains
  # the same.
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
