# frozen_string_literal: true

describe ::Question::Ruby::Application::SymbolIndex do
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
    it "finds namespaces" do
      matches = application.symbol_index.search("Application")

      expect(matches[0].document.record).to have_attributes(
        itself: be_a(::Question::Ruby::Namespace::Record),
        name: "MyApplication",
      )
    end

    # TODO: find references? find method declarations? find lambda declarations?
    # This should be optimized for the "I know what I'm looking for" mode, and not the exploration mode.
  end
end
