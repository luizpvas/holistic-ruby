# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::ScopeReference do
  include ::Support::SnippetParser

  context "when a scope is referenced with nested syntax with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::MyLib::String.new
      end
      RUBY
    end

    it "infers the scope reference clue" do
      reference = application.references.find_reference_to("::MyLib::String.new")

      expect(reference.clues.size).to be(1)
      reference.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("::MyLib::String.new")
        expect(clue.resolution_possibilities).to eql(["::MyApp", "::"])
      end
    end
  end

  context "when a scope from stdlib is referenced with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::String.new
      end
      RUBY
    end

    it "infers a scope reference clue" do
      reference = application.references.find_reference_to("::String.new")

      expect(reference.clues.size).to be(1)
      reference.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("::String.new")
        expect(clue.resolution_possibilities).to eql(["::MyApp", "::"])
      end
    end
  end
end
