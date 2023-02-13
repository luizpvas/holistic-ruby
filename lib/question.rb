# frozen_string_literal: true

require "zeitwerk"
require "syntax_tree"

loader = ::Zeitwerk::Loader.for_gem
loader.setup

module Question; end

loader.eager_load
