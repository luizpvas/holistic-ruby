# frozen_string_literal: true

module Holistic::LanguageServer
  module Stdio::Start
    extend self

    def call
      ::Holistic.logger.info("starting holistic-ruby server on dir: #{::Dir.getwd}")

      start_language_server_lifecycle!

      server = Stdio::Server.new
      parser = Stdio::Parser.new
      
      server.start_input_loop do |payload|
        parser.ingest(payload)

        while parser.completed?
          response = ::Holistic::LanguageServer::Router.dispatch(parser.message)

          case response
          in Response::Success  then server.write_to_output(response.encode)
          in Response::Error    then server.write_to_output(response.encode)
          in Response::NotFound then nil
          in Response::Exit     then server.stop!
          end
          
          parser.clear
        end
      end

      ::Holistic.logger.info("closing holistic-ruby server on dir #{::Dir.getwd}")
    rescue ::StandardError => err
      ::Holistic.logger.info("crash from Stdio::Start")
      ::Holistic.logger.info(err.inspect)
      ::Holistic.logger.info(err.backtrace)

      raise err
    end

    private

    def start_language_server_lifecycle!
      ::Holistic::LanguageServer::Current.lifecycle = ::Holistic::LanguageServer::Lifecycle.new
    end
  end
end
