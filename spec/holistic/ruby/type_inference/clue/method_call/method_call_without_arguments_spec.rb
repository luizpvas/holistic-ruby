# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::MethodCall do
  include ::Support::SnippetParser

  context "when calling methods without arguments" do
    let(:application) do
      parse_snippet <<~RUBY
      class Example; end

      example = Example.new
      example.do_something
      RUBY
    end

    it "registers references with the method call clue" do
      reference_to_new = application.references.find_by_code_content("Example.new")
      
      expect(reference_to_new.clues.size).to be(1)
      reference_to_new.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("Example.new")
        expect(clue.resolution_possibilities).to eql(["::"])
      end

      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      reference_to_do_something.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("example.do_something")
        expect(clue.resolution_possibilities).to eql(["::"])
      end
    end
  end

  context "when chaining methods without arguments" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something.do_something_else
      RUBY
    end

    it "registers a reference for each call" do
      expect(
        application.references.find_by_code_content("example")
      ).to be_a(::Holistic::Ruby::Reference::Record)

      expect(
        application.references.find_by_code_content("example.do_something")
      ).to be_a(::Holistic::Ruby::Reference::Record)

      expect(
        application.references.find_by_code_content("example.do_something.do_something_else")
      ).to be_a(::Holistic::Ruby::Reference::Record)
    end
  end
end
