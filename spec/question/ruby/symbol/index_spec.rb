# frozen_string_literal: true

describe ::Question::Ruby::Symbol::Index do
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
    it "finds namespace declarations" do
      matches = application.symbol_index.search("Application")

      expect(matches[0].document).to have_attributes(
        identifier: "::MyApplication",
        text: "::MyApplication"
      )
    end

    # TODO: find references? find method declarations? find lambda declarations?
    # This should be optimized for the "I know what I'm looking for" mode, and not the exploration mode.
  end
end
