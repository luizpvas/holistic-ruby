# frozen_string_literal: true

module Holistic::Ruby::Parser
  HasValidSyntax = ->(content) do
    ::SyntaxTree.parse(content)

    true
  rescue ::SyntaxTree::Parser::ParseError
    false
  end

  ParseFile = ->(application:, file_path:, content:) do
    ::Holistic.logger.info(file_path)

    program = ::SyntaxTree.parse(content)

    constant_resolution = ConstantResolution.new(scope_repository: application.scopes)

    file = ::Holistic::Document::File::Store.call(database: application.database, file_path:)

    visitor = ProgramVisitor.new(application:, constant_resolution:, file:)

    visitor.visit(program)
  rescue ::SyntaxTree::Parser::ParseError
    ::Holistic.logger.info("syntax error on file #{file_path}")
  end

  class PerformanceMetrics
    def initialize
      @amount_of_files  = 0
      @total_read_time  = 0
      @total_parse_time = 0
    end

    def start_file_read!
      @amount_of_files += 1
      @file_read_before = ::Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def end_file_read!
      @total_read_time += ::Process.clock_gettime(Process::CLOCK_MONOTONIC) - @file_read_before
    end

    def start_parse!
      @parse_before = ::Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def end_parse!
      @total_parse_time += ::Process.clock_gettime(Process::CLOCK_MONOTONIC) - @parse_before
    end

    def inspect
      {
        amount_of_files:  @amount_of_files,
        total_read_time:  @total_read_time,
        total_parse_time: @total_parse_time
      }.inspect
    end
  end

  ParseDirectory = ->(application:, directory_path:) do
    performance_metrics = PerformanceMetrics.new

    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      performance_metrics.start_file_read!
      content = ::File.read(file_path)
      performance_metrics.end_file_read!

      performance_metrics.start_parse!
      ParseFile.call(application:, file_path:, content:)
      performance_metrics.end_parse!
    end

    performance_metrics
  end
end
