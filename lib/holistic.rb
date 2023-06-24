# frozen_string_literal: true

require "logger"
require "zeitwerk"
require "syntax_tree"

loader = ::Zeitwerk::Loader.for_gem
loader.setup

module Holistic
  extend self

  @logger = ::Logger.new("/home/luiz.vasconcellos/holistic.log")
  attr_reader :logger
end

loader.eager_load
