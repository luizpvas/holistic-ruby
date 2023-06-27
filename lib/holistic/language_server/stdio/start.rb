# frozen_string_literal: true

module Holistic::LanguageServer::Stdio
  module Start
    extend self

    def call
      server = Server.new
      parser = Parser.new
      
      server.start_input_loop do |payload|
        parser.ingest(payload)

        while parser.completed?
          message = ::Holistic::LanguageServer::Message.new(parser.message)

          ::Holistic::LanguageServer::Router.dispatch(message)&.then do |response|
            if response.exit?
              server.stop!
            else
              server.write_to_output(response.encode)
            end
          end

          parser.clear
        end
      end

      ::Holistic.logger.info("all good, bye!")
    rescue ::StandardError => err
      ::Holistic.logger.info("crash from Stdio::Start")
      ::Holistic.logger.info(err.inspect)

      raise err
    end
  end
end
