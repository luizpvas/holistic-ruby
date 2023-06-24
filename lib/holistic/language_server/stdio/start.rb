# frozen_string_literal: true

module Holistic::LanguageServer::Stdio
  module Start
    extend self

    def call
      server = Server.new
      message_parser = MessageParser.new
      
      server.on_data_received do |payload|
        message_parser.ingest(payload)

        if message_parser.completed?
          ::Holistic.logger.info("completed message!")

          ::Holistic.logger.info(message_parser.message)

          # TODO: handle the message

          message_parser.clear
        end
      end

      server.start_input_thread!
    end
  end
end
