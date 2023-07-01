# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Outline do
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
    result = described_class.call(application:, symbol: application.symbols.find("::MyApp::Example"))

    expect(result.references).to be_empty
    expect(result.dependants).to be_empty

    expect(result.declarations.map(&:identifier)).to match_array([
      "::MyApp::Example::PlusThree"
    ])

    dependencies = result.dependencies.map { _1.record.conclusion.dependency_identifier }

    expect(dependencies).to match_array([
      "::MyApp::PlusOne",
      "::MyApp::PlusTwo"
    ])
  end
end