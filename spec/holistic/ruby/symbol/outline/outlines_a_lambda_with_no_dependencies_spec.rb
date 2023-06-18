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

    expect(result.declarations).to be_empty
    expect(result.dependencies).to be_empty

    expect(result.references.map(&:identifier)).to match_array([
      "::MyApp::Calc"
    ])
  end
end
