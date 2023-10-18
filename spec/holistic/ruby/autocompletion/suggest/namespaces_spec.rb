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
      class Payment
      end

      Payout = ::Data.define do
      end

      Calculate = ->(a, b) { a + b }

      class EventsController
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
    assert_suggestions("Fe", [{ code: "Feed", kind: :module }])
  end

  it "suggests Feed::" do
    assert_suggestions("Feed::", [{ code: "Item", kind: :module }])
  end

  it "suggests Ev" do
    assert_suggestions("Ev", [{code: "EventsController", kind: :class }])
  end

  it "suggests Pay" do
    assert_suggestions("Pay", [
      { code: "Payment", kind: :class },
      { code: "Payout", kind: :class }
    ])
  end

  it "suggests Paym" do
    assert_suggestions("Paym", [{ code: "Payment", kind: :class }])
  end

  it "suggests Payo" do
    assert_suggestions("Payo", [{ code: "Payout", kind: :class }])
  end

  it "suggests My" do
    assert_suggestions("My", [{ code: "MyApp", kind: :module }])
  end

  it "suggests ::My" do
    assert_suggestions("::My", [{ code: "MyApp", kind: :module }])
  end

  it "suggests ::MyApp::" do
    assert_suggestions("::MyApp::", [
      { code: "Payment", kind: :class },
      { code: "Payout", kind: :class },
      { code: "Calculate", kind: :lambda }, 
      { code: "EventsController", kind: :class }
    ])
  end

  it "suggests ::MyApp::Pay" do
    assert_suggestions("::MyApp::Pay", [
      { code: "Payment", kind: :class },
      { code: "Payout", kind: :class }
    ])
  end

  it "suggests ::MyApp::Ev" do
    assert_suggestions("::MyApp::Ev", [{ code: "EventsController", kind: :class }])
  end

  it "suggests ::MyApp::EventsController::" do
    assert_suggestions("::MyApp::EventsController::", [{ code: "Feed", kind: :module }])
  end
end