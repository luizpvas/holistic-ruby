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

          ::Holistic::LanguageServer::Router.call(message)

          parser.clear
        end
      end

      server.start_input_thread!
    end
  end
end
