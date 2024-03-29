# frozen_string_literal: true

class Holistic::Extensions::Events
  TOPICS = {
    # TODO: remove
    resolve_method_call_known_scope: {
      params: [:referenced_scope, :method_call_clue],
      output: ::Holistic::Ruby::Scope::Record
    },
    class_scope_registered: {
      params: [:class_scope, :location],
      output: nil
    },
    lambda_scope_registered: {
      params: [:lambda_scope, :location],
      output: nil
    }
  }.freeze

  UnknownEvent         = ::Class.new(::StandardError)
  MissingRequiredParam = ::Class.new(::StandardError)
  UnexpectedOutput     = ::Class.new(::StandardError)

  def initialize
    @listeners = Hash.new { |hash, key| hash[key] = [] }
  end

  def bind(event, &callback)
    raise UnknownEvent, event unless TOPICS.key?(event)

    @listeners[event] << callback
  end

  def dispatch(event, params)
    required_params = TOPICS.dig(event, :params)
    expected_output = TOPICS.dig(event, :output)

    raise MissingRequiredParam, required_params if (required_params - params.keys).any?

    result = @listeners[event].lazy.filter_map { |callback| callback.call(params) }.first

    raise UnexpectedOutput, result if expected_output.present? && result.present? && !result.is_a?(expected_output)

    result
  end
end
