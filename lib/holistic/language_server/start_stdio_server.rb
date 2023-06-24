# frozen_string_literal: true

module Holistic::LanguageServer
  module StartStdioServer
    extend self

    class Server
      def initialize
        @input = STDIN
        @output = STDOUT
        @stopped = false

        set_output_to_binary_mode!
      end

      def start_input_thread!
        Thread.new do
          read_input until @stopped
        end

        sleep 0.1 until @stopped
      end

      private

      def set_output_to_binary_mode!
        @output.binmode
      end

      def read_input
        ::Holistic.logger.info("initializing #read_input")

        begin
          @input.flush
          payload = @input.sysread(255)

          ::Holistic.logger.info("================================")
          ::Holistic.logger.info(payload)
        rescue ::EOFError, ::IOError, ::Errno::ECONNRESET, ::Errno::ENOTSOCK
          @stopped = true
        end
      end
    end

    def call
      server = Server.new
      server.start_input_thread!
    end
  end
end
