# frozen_string_literal: true

describe ::Question::Ruby::Application::Symbol::Search do
  include SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApplication
      class MyController
        def index
          result = MyService.call(user: current_user)
        end
      end
    end
    RUBY
  end

  describe ".call" do
    it "finds namespaces"
    it "finds references"
    it "finds method declarations"
    it "finds lambda declarations"
  end
end
