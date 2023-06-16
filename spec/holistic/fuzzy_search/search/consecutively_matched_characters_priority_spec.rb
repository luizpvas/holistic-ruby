# frozen_string_literal: true

describe ::Holistic::FuzzySearch::Search do
  let(:documents) do
    [
      "::Holistic::Ruby::Application::SymbolIndex",
      "::Holistic::Ruby::Parser::Visitor::Node"
    ].map { |text| ::Holistic::FuzzySearch::Document.new(text:) }
  end

  it "returns the document with the full word match first" do
    matches = described_class.call(query: "ode", documents:).matches

    expect(matches.pluck(:highlighted_text)).to eql([
      "::Holistic::Ruby::Parser::Visitor::N<em>ode</em>",
      "::H<em>o</em>listic::Ruby::Application::SymbolIn<em>de</em>x"
    ])
  end
end
