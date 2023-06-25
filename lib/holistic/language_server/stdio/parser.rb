# frozen_string_literal: true

module Holistic::LanguageServer
  class Stdio::Parser
    CONTENT_LENGTH_HEADER = "Content-Length"
    END_OF_HEADER = "\r\n\r\n"

    MissingContentLengthHeaderError = ::Class.new(::StandardError)

    # TODO: remove `left_over_from_previous_ingestion`. The same behaviour can be achieved with only the buffer.

    def initialize
      @buffer = ::String.new
      @left_over_from_previous_ingestion = ::String.new
      @in_header = true
      @content_length = 0
    end

    def ingest(payload)
      payload.each_char do |char|
        if @in_header || !completed?
          @buffer.concat(char)
        else
          @left_over_from_previous_ingestion.concat(char)
        end

        if @in_header
          prepare_to_parse_message! if @buffer.end_with?(END_OF_HEADER)
        end
      end
    end

    def completed?
      !@in_header && @content_length == @buffer.length
    end

    def has_left_over?
      !@left_over_from_previous_ingestion.empty?
    end

    # TODO: rename `message` to `decode` or `decode_message`

    def message
      ::JSON.parse(@buffer)
    end

    def clear
      left_over = @left_over_from_previous_ingestion.dup
      @left_over_from_previous_ingestion.clear

      @buffer.clear
      @in_header = true
      @content_length = 0

      ingest(left_over) if !left_over.empty?
    end

    private

    def prepare_to_parse_message!
      @buffer.each_line do |line|
        key, value = line.split(":").map(&:strip)

        if key == CONTENT_LENGTH_HEADER
          @in_header = false
          @content_length = Integer(value)
          @buffer.clear

          return
        end
      end

      raise MissingContentLengthHeaderError, @buffer
    end
  end
end
