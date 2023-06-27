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
          response = ::Holistic::LanguageServer::Router.dispatch(parser.message)

          case response.status
          when Response::Status::OK        then server.write_to_output(response.encode)
          when Response::Status::NOT_FOUND then nil
          when Response::Status::EXIT      then server.stop!
          else raise "unexpected response status: #{response.status}"
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
