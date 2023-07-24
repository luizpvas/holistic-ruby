# frozen_string_literal: true

module Holistic::LanguageServer
  class Stdio::Parser
    MissingContentLengthHeaderError = ::Class.new(::StandardError)

    def initialize
      @buffer = ::String.new
      @overflow_from_previous_ingestion = ::String.new
      @in_header = true
      @content_length = 0
    end

    def ingest(payload)
      payload.each_char do |char|
        if @in_header || !completed?
          @buffer.concat(char)
        else
          @overflow_from_previous_ingestion.concat(char)
        end

        if @in_header
          prepare_to_parse_message! if @buffer.end_with?(Protocol::END_OF_HEADER)
        end
      end
    end

    def completed?
      !@in_header && @content_length == @buffer.length
    end

    def message
      Message.new(::JSON.parse(@buffer))
    end

    def clear
      left_over = @overflow_from_previous_ingestion.dup
      @overflow_from_previous_ingestion.clear

      @buffer.clear
      @in_header = true
      @content_length = 0

      ingest(left_over) if !left_over.empty?
    end

    private

    def prepare_to_parse_message!
      @buffer.each_line do |line|
        key, value = line.split(":").map(&:strip)

        if key == Protocol::CONTENT_LENGTH_HEADER
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
