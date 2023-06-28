# frozen_string_literal: true

require "debug"
require "holistic"

require_relative "support/snippet_parser"
require_relative "support/language_server/factory"

::RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
