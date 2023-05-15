# frozen_string_literal: true

module Question::Ruby
  module Constant
    Reference = ::Struct.new(:name, :resolution, keyword_init: true)
  end
end
