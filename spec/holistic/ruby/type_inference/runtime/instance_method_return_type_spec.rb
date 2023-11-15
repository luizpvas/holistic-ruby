# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::TypeInference::Runtime do
  include ::Support::SnippetExecutor

  let(:application) do
    execute_script <<~RUBY
    module MyApp
      class Bar; end

      class Foo
        def bar = Bar.new
      end
    end

    MyApp::Foo.new.bar
    RUBY
  end
end

