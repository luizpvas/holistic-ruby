# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::MethodCall do
  include ::Support::SnippetParser

  context "call to method without arguments" do
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
      expect(reference_to_new.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("Example"),
        method_name: "new",
        resolution_possibilities: ["::"]
      )

      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      expect(reference_to_do_something.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )
    end
  end
end
