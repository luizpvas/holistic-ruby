# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Outline do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      PlusOne = ->(x) { x + 1 }
      PlusTwo = ->(x) { x + 2 }

      module Example
        PlusThree = ->(x) { x + 3 }

        PlusOne.call(1)
        PlusTwo.call(2)
        PlusThree.call(3)
      end
    end
    RUBY
  end

  it "outlines a module with dependencies declared outside of the outlined module" do
    result = described_class.call(application:, scope: application.scopes.find("::MyApp::Example"))

    expect(result.references).to be_empty
    expect(result.dependants).to be_empty

    expect(
      result.declarations.map { _1.fully_qualified_name }
    ).to match_array([
      "::MyApp::Example::PlusThree",
      "::MyApp::Example::PlusThree.call",
      "::MyApp::Example::PlusThree.curry"
    ])

    dependencies = 

    expect(
      result.dependencies.map { _1.referenced_scope.fully_qualified_name }
    ).to match_array([
      "::MyApp::PlusOne",
      "::MyApp::PlusOne.call",
      "::MyApp::PlusTwo",
      "::MyApp::PlusTwo.call"
    ])
  end
end