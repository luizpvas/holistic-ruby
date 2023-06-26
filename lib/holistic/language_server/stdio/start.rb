# frozen_string_literal: true

module Holistic::LanguageServer::Stdio
  module Start
    extend self

    def call
      server = Server.new
      parser = Parser.new
      
      server.on_data_received do |payload|
        parser.ingest(payload)

        while parser.completed?
          message = ::Holistic::LanguageServer::Message.new(parser.message)

          response = ::Holistic::LanguageServer::Router.dispatch(message)

          if response.exit?
            server.stop!
          else
            server.send_response!(response.to_json)
          end

          parser.clear
        end
      end

      server.start_read_input_loop!

      ::Holistic.logger.info("all good, bye!")
    rescue ::StandardError => err
      ::Holistic.logger.info("crash from Stdio::Start")
      ::Holistic.logger.info(err.inspect)

      raise err
    end
  end
end
