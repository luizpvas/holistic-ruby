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

  context "when chaining methods without arguments" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something.do_something_else
      RUBY
    end

    it "registers a reference for each call" do
      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      expect(reference_to_do_something.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )

      reference_to_do_something_else = application.references.find_by_code_content("do_something.do_something_else")

      expect(reference_to_do_something_else.clues.size).to be(1)
      expect(reference_to_do_something_else.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("do_something"),
        method_name: "do_something_else",
        resolution_possibilities: ["::"]
      )
    end
  end
end
