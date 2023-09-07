# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggest do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child.child_method")

      actual_suggestions = described_class.call(code:, scope:)

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
        def self.parent_method
        end
      end

      class Child < Parent
        def self.child_method
          # autocomplete here
        end
      end
    end
    RUBY
  end

  it "suggests methods of the parent class from the child class scope" do
    assert_suggestions("p", [
      { code: "parent_method", kind: :class_method }
    ])
  end

  it "suggests methods from parent from the fully qualified child scope name" do
    assert_suggestions("::MyApp::Child.", [
      { code: "child_method", kind: :class_method },
      { code: "new", kind: :class_method },
      { code: "parent_method", kind: :class_method }
    ])
  end
end
