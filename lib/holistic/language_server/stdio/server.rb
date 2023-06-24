# frozen_string_literal: true

module Holistic::LanguageServer::Stdio
  class Server
    def initialize(input = STDIN, output = STDOUT)
      @input = input
      @output = output
      @stopped = false
      @on_data_received = -> { raise ::NotImplementedError }

      set_output_to_binary_mode!
    end

    def on_data_received(&block)
      @on_data_received = block
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
      begin
        @input.flush
        payload = @input.sysread(255)
        
        @on_data_received.call(payload)
      rescue ::EOFError, ::IOError, ::Errno::ECONNRESET, ::Errno::ENOTSOCK
        @stopped = true
      end
    end
  end
end
