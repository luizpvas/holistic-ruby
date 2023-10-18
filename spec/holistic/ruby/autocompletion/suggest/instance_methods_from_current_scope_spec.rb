# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::EventsController#index")

      piece_of_code = ::Holistic::Ruby::Autocompletion::PieceOfCode.new(code)
      actual_suggestions = described_class.call(piece_of_code:, scope:)

      expected_suggestions = suggestions.map do |suggestion|
        described_class::Suggestion.new(code: suggestion[:code], kind: suggestion[:kind])
      end

      expect(actual_suggestions).to eql(expected_suggestions)
    end
  end

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      class EventsController
        Lambda1 = ->{ nil }

        def index
          # autocomplete here
        end

        def method_1
        end

        private

        def method_2
        end
      end
    end
    RUBY
  end

  it "suggests met" do
    assert_suggestions("met", [
      { code: "method_1", kind: :instance_method },
      { code: "method_2", kind: :instance_method }
    ])
  end

  it "suggests Lam" do
    assert_suggestions("Lam", [
      { code: "Lambda1", kind: :lambda }
    ])
  end
end
