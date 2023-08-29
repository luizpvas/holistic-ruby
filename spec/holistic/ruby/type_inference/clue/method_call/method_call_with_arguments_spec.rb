# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Clue::MethodCall do
  include ::Support::SnippetParser

  context "when calling methods with arguments" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something("foo", another_thing)
      RUBY
    end

    it "registers the reference" do
      reference = application.references.find_by_code_content("example.do_something")

      expect(reference.clues.size).to be(1)
      expect(reference.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )
    end
  end

  context "when calling methods with argument where argument is another method call" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something(example.value)
      RUBY
    end

    it "registers the references" do
      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      expect(reference_to_do_something.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )

      reference_to_value = application.references.find_by_code_content("example.value")

      expect(reference_to_value.clues.size).to be(1)
      expect(reference_to_value.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "value",
        resolution_possibilities: ["::"]
      )
    end
  end

  context "when calling methods with arguments and a block with the do syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something("foo", [1, 2, 3]) do |arg|
        arg.do_something_else
      end
      RUBY
    end

    it "registers the references" do
      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      expect(reference_to_do_something.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )

      reference_to_do_something_else = application.references.find_by_code_content("arg.do_something_else")

      expect(reference_to_do_something_else.clues.size).to be(1)
      expect(reference_to_do_something_else.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("arg"),
        method_name: "do_something_else",
        resolution_possibilities: ["::"]
      )
    end
  end

  context "when calling methods with arguments and a block with the ampersand syntax" do
    let(:application) do
      parse_snippet <<~RUBY
      callback = ->(arg) { arg.do_something_else }

      example.do_something("foo", &callback)
      RUBY
    end

    it "registers the references" do
      reference_to_do_something = application.references.find_by_code_content("example.do_something")

      expect(reference_to_do_something.clues.size).to be(1)
      expect(reference_to_do_something.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("example"),
        method_name: "do_something",
        resolution_possibilities: ["::"]
      )

      reference_to_do_something_else = application.references.find_by_code_content("arg.do_something_else")

      expect(reference_to_do_something_else.clues.size).to be(1)
      expect(reference_to_do_something_else.clues.first).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall),
        nesting: ::Holistic::Ruby::Parser::NestingSyntax.new("arg"),
        method_name: "do_something_else",
        resolution_possibilities: ["::"]
      )
    end
  end
end
