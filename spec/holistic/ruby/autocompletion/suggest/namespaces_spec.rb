# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::EventsController#index")

      actual_suggestions = described_class.call(code:, scope:)
      expected_suggestions = suggestions.map { described_class::Suggestion.new(code: _1) }

      expect(actual_suggestions).to eql(expected_suggestions)
    end
  end

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      class Payment
      end

      Payout = ::Data.define

      Calculate = ->(a, b) { a + b }

      module EventsController
        module Feed
          module Item; end
        end

        def index
          # autocomplete here
        end
      end
    end
    RUBY
  end

  it "suggests Unknown" do
    assert_suggestions("Unknown", [])
  end

  it "suggests Fee" do
    assert_suggestions("Fe", ["Feed"])
  end

  it "suggests Feed::" do
    assert_suggestions("Feed::", ["Item"])
  end

  it "suggests Ev" do
    assert_suggestions("Ev", ["EventsController"])
  end

  it "suggests Pay" do
    assert_suggestions("Pay", ["Payment", "Payout"])
  end

  it "suggests Paym" do
    assert_suggestions("Paym", ["Payment"])
  end

  it "suggests Payo" do
    assert_suggestions("Payo", ["Payout"])
  end

  it "suggests My" do
    assert_suggestions("My", ["MyApp"])
  end

  it "suggests ::My" do
    assert_suggestions("::My", ["MyApp"])
  end

  it "suggests ::MyApp::" do
    assert_suggestions("::MyApp::", ["Payment", "Payout", "Calculate", "EventsController"])
  end

  it "suggests ::MyApp::Pay" do
    assert_suggestions("::MyApp::Pay", ["Payment", "Payout"])
  end

  it "suggests ::MyApp::Ev" do
    assert_suggestions("::MyApp::Ev", ["EventsController"])
  end

  it "suggests ::MyApp::EventsController::" do
    assert_suggestions("::MyApp::EventsController::", ["Feed"])
  end

  it "suggests ::MyApp::EventsController" do
    assert_suggestions("::MyApp::EventsController", ["::Feed"])
  end
end