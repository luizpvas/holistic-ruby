# frozen_string_literal: true

describe ::Holistic::FuzzySearch::Search do
  let(:documents) do
    [
      "MyApplication",
      "MyApplication::MyClass",
      "MyApplication::MyClass::Foo"
    ].map { |text| ::Holistic::FuzzySearch::Document.new(text:) }
  end

  let(:examples) do
    [
      { query: "M",    expected_first_result: "<em>M</em>yApplication" },
      { query: "p",    expected_first_result: "MyA<em>p</em>plication" },
      { query: "pp",   expected_first_result: "MyA<em>pp</em>lication" },
      { query: "MyMy", expected_first_result: "<em>My</em>Application::<em>My</em>Class" },
      { query: "Foo",  expected_first_result: "MyApplication::MyClass::<em>Foo</em>" },
    ]
  end

  it "returns the expected results" do
    examples.each do |example|
      matches = described_class.call(query: example[:query], documents:).matches

      expect(matches[0].highlighted_text).to eql(example[:expected_first_result])
    end
  end
end