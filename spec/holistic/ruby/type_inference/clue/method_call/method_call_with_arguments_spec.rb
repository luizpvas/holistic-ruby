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
      reference = application.references.find_by_code_content('example.do_something("foo", another_thing)')

      expect(reference.clues.size).to be(1)

      reference.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql('example.do_something("foo", another_thing)')
        expect(clue.resolution_possibilities).to eql(["::"])
      end
    end
  end

  context "when calling methods with argument where argument is another method call" do
    let(:application) do
      parse_snippet <<~RUBY
      example.do_something(example.value)
      RUBY
    end

    it "registers the references" do
      reference_to_do_something = application.references.find_by_code_content("example.do_something(example.value)")

      expect(reference_to_do_something.clues.size).to be(1)
      reference_to_do_something.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("example.do_something(example.value)")
        expect(clue.resolution_possibilities).to eql(["::"])
      end

      reference_to_value = application.references.find_by_code_content("example.value")

      expect(reference_to_value.clues.size).to be(1)
      reference_to_value.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("example.value")
        expect(clue.resolution_possibilities).to eql(["::"])
      end
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
      reference_to_do_something = application.references.find_by_code_content('example.do_something("foo", [1, 2, 3])')

      expect(reference_to_do_something.clues.size).to be(1)
      reference_to_do_something.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql('example.do_something("foo", [1, 2, 3])')
        expect(clue.resolution_possibilities).to eql(["::"])
      end

      reference_to_do_something_else = application.references.find_by_code_content("arg.do_something_else")

      expect(reference_to_do_something_else.clues.size).to be(1)
      reference_to_do_something_else.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("arg.do_something_else")
        expect(clue.resolution_possibilities).to eql(["::"])
      end
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
      reference_to_do_something = application.references.find_by_code_content('example.do_something("foo", &callback)')

      expect(reference_to_do_something.clues.size).to be(1)
      reference_to_do_something.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql('example.do_something("foo", &callback)')
        expect(clue.resolution_possibilities).to eql(["::"])
      end

      reference_to_do_something_else = application.references.find_by_code_content("arg.do_something_else")

      expect(reference_to_do_something_else.clues.size).to be(1)
      reference_to_do_something_else.clues.first.tap do |clue|
        expect(clue).to be_a(::Holistic::Ruby::TypeInference::Clue::MethodCall)
        expect(clue.expression.to_s).to eql("arg.do_something_else")
        expect(clue.resolution_possibilities).to eql(["::"])
      end
    end
  end
end
