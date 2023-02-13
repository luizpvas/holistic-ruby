# frozen_string_literal: true

module Question::Ruby
  module Constant
    Reference = ::Struct.new(:name, :namespace, keyword_init: true)
  end
end
