# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced inside class methods" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class MyClass
          def foo = Example.call
        end
      end
      RUBY
    end

    it "infers a scope reference clue" do
      reference = application.references.find_by_code_content("Example.call")

      expect(reference.clues.size).to be(1)
      reference.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("Example.call")
        expect(clue.resolution_possibilities).to eql(["::MyApp::MyClass", "::MyApp", "::"])
      end
    end
  end
end
