::ActiveSupport::Notifications.subscribe("holistic.language_server.request") do |name, started, finished, id, data|
  ::Holistic.logger.info({
    message: data[:request].message.inspect,
    response: data[:request].response.inspect
  }.to_json)
end