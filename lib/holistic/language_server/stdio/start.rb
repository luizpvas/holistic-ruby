# frozen_string_literal: true

module Holistic::LanguageServer
  module Stdio::Start
    extend self

    def call
      server = Stdio::Server.new
      parser = Stdio::Parser.new
      
      server.start_input_loop do |payload|
        parser.ingest(payload)

        while parser.completed?
          response = ::Holistic::LanguageServer::Router.dispatch(parser.message)

          case response
          in Response::Success  then server.write_to_output(response.encode)
          in Response::NotFound then nil
          in Response::Exit     then server.stop!
          else raise "unexpected response: #{response}"
          end
          
          parser.clear
        end
      end

      ::Holistic.logger.info("all good, bye!")
    rescue ::StandardError => err
      ::Holistic.logger.info("crash from Stdio::Start")
      ::Holistic.logger.info(err.inspect)
      ::Holistic.logger.info(err.backtrace)

      raise err
    end
  end
end
