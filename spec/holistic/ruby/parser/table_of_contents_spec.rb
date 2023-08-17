# frozen_string_literal: true

describe ::Holistic::Ruby::Parser::TableOfContents do
  describe "#register" do
    let(:table_of_contents) { described_class.new }

    it "adds a new clue for the identifier" do
      scope = ::Holistic::Ruby::Scope::Record.new(kind: :module, name: "MyApp", parent: nil)
      name  = "my_variable"
      clue  = ::Holistic::Ruby::TypeInference::Clue::MethodCall.new(nesting: nil, method_name: nil, resolution_possibilities: nil)

      expect(table_of_contents.records).to be_empty

      table_of_contents.register(scope:, name:, clue:)

      expect(table_of_contents.records[scope.fully_qualified_name][name]).to eql([clue])
    end
  end
end
