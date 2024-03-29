# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::MethodCall do
  include ::Support::SnippetParser

  context "when calling a method on a literal hash" do
    let(:application) do
      parse_snippet <<~RUBY
      { "foo" => "bar" }.freeze
      RUBY
    end

    it "does not register a reference" do
      expect(application.references.all.size).to be(1)
    end
  end
end
