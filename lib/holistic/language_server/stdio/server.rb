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

    def start_read_input_loop!
      read_input until @stopped
    end

    def send_response!(payload)
      @output.write(payload)
      @output.flush
    end

    def stop!
      @stopped = true
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
