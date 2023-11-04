# frozen_string_literal: true

require "json"
require "uri"
require "logger"

require "zeitwerk"
require "syntax_tree"

require "active_support/concern"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/module/concerning"
require "active_support/notifications"
require "active_support/inflector"

require_relative "../config/logging"

loader = ::Zeitwerk::Loader.for_gem
loader.setup

module Holistic
  extend self

  @logger = ::Logger.new(ENV["HOLISTIC_LOG_OUTPUT"])
  attr_reader :logger
end

loader.eager_load
