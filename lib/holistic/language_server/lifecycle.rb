# frozen_string_literal: true

module Holistic::LanguageServer
  # Lifecycle constraints:
  #
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#shutdown
  class Lifecycle
    UnexpectedStateError = ::Class.new(::StandardError)

    attr_reader :state

    def initialize
      @state = :waiting_initialize_event
    end

    def waiting_initialized_event!
      if @state != :waiting_initialize_event
        raise UnexpectedStateError, "state must be :waiting_initialize_event, got: #{@state.inspect}"
      end

      @state = :waiting_initialized_event
    end

    def initialized!
      if @state != :waiting_initialized_event
        raise UnexpectedStateError, "state must be :waiting_initialized_event, got: #{@state.inspect}"
      end

      @state = :initialized
    end

    def shutdown!
      if @state != :initialized
        raise UnexpectedStateError, "state must be :initialized, got: #{@state.inspect}"
      end

      @state = :shutdown
    end

    def initialized?
      @state == :initialized || @state == :shutdown
    end

    def accept?(method)
      return true if method == "exit"
      return true if method == "initialize" && @state == :waiting_initialize_event
      return true if method == "initialized" && @state == :waiting_initialized_event
      
      return method != "initialize" && method != "initialized" if @state == :initialized

      false
    end

    def reject?(method)
      !accept?(method)
    end
  end
end
