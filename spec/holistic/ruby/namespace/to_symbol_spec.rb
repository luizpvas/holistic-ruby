# frozen_string_literal: true

describe ::Holistic::Ruby::Namespace::ToSymbol do
  describe ".call" do
    it "builds a symbol entity from a namespace" do
      source_location = ::Holistic::SourceCode::Location.new

      namespace = ::Holistic::Ruby::Namespace::Record.new(
        kind: :module,
        name: "MyApp",
        parent: ::Holistic::Ruby::Namespace::Record.new(kind: :root, name: "::", parent: nil),
        source_location: source_location
      )

      symbol = described_class.call(namespace)

      expect(symbol).to have_attributes(
        itself: be_a(::Holistic::Ruby::Symbol::Record),
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        source_locations: [source_location]
      )
    end
  end
end
