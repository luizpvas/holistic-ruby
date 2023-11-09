# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::MethodCall do
  include ::Support::SnippetParser

  context "when calling a method on a local variable" do
    let(:application) do
      parse_snippet <<~RUBY
      user.nickname
      RUBY
    end

    it "registers the method call clue" do
      reference = application.references.find_by_code_content("user.nickname")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        expression: ::Holistic::Ruby::Parser::Expression.new("user"),
        method_name: "nickname",
        resolution_possibilities: ["::"]
      )
    end
  end
end
