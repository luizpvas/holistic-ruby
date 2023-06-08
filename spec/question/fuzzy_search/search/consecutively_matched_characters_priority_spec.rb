# frozen_string_literal: true

describe ::Question::FuzzySearch::Search do
  let(:documents) do
    [
      "::Question::Ruby::Application::SymbolIndex",
      "::Question::Ruby::Parser::Visitor::Node"
    ].map { |text| ::Question::FuzzySearch::Document.new(text:) }
  end

  it "returns the document with the full word match first" do
    matches = described_class.call(query: "node", documents:).matches

    expect(matches.pluck(:highlighted_text)).to eql([
      "::Question::Ruby::Parser::Visitor::<em>Node</em>",
      "::Questio<em>n</em>::Ruby::Applicati<em>o</em>n::SymbolIn<em>de</em>x"
    ])
  end
end
