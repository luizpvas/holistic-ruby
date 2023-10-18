# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child#child_method")

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
      class Parent
        def parent_method
        end

        def overriden_method
        end
      end

      class Child < Parent
        def child_method
          # autocomplete here
        end

        def overriden_method
        end
      end
    end
    RUBY
  end

  it "suggests p" do
    assert_suggestions("p", [
      { code: "parent_method", kind: :instance_method }
    ])
  end

  it "suggests o" do
    assert_suggestions("o", [
      { code: "overriden_method", kind: :instance_method }
    ])
  end
end
