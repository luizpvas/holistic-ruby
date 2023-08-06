# frozen_string_literal: true

class Holistic::Extensions::Events
  TOPICS = {
    resolve_method_call_known_scope: {
      params: [:reference, :referenced_scope, :method_call_clue],
      output: ::Holistic::Ruby::Scope::Record
    }
  }.freeze

  def initialize
    @listeners = Hash.new{ |hash, key| hash[key] = [] }
  end

  UnknownEvent         = ::Class.new(::StandardError)
  MissingRequiredParam = ::Class.new(::StandardError)
  UnexpectedOutput     = ::Class.new(::StandardError)

  def bind(event, &callback)
    raise UnknownEvent, event unless TOPICS.key?(event)

    @listeners[event] << callback
  end

  def dispatch(event, **args)
    required_params = TOPICS.dig(event, :params)
    expected_output = TOPICS.dig(event, :output)

    raise MissingRequiredParam, required_params if (required_params - args.keys).any?

    result = @listeners[event].lazy.filter_map { |callback| callback.call(**args) }.first

    raise UnexpectedOutput, result if result.present? && !result.is_a?(expected_output)

    result
  end
end