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
      
      reference.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("user.nickname")
        expect(clue.resolution_possibilities).to eql(["::"])
      end
    end
  end
end
