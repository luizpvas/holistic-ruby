# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Outline do
  include ::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      PlusOne = ->(x) { x + 1 }

      module Calc
        PlusOne.call(2)
      end
    end
    RUBY
  end

  it "outlines a lambda with no dependencies and a single reference" do
    result = described_class.call(application:, symbol: application.symbols.find("::MyApp::PlusOne"))

    expect(result.dependencies).to be_empty
    expect(result.declarations).to be_empty

    expect(result.references.map(&:record)).to match_array([
      application.symbols.find_reference_to("PlusOne")
    ])

    expect(result.dependants.map(&:fully_qualified_name)).to match_array([
      "::MyApp::Calc"
    ])
  end
end
