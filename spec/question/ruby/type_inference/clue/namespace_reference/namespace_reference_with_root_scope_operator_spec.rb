# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Clue::NamespaceReference do
  include ::SnippetParser

  context "nested reference with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::MyLib::String.new
      end
      RUBY
    end

    it "infers the namespace reference clue" do
      expect(application.symbols.find_reference_to("MyLib::String")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            name: "MyLib::String",
            resolution_possibilities: ["::"]
          )
        ]
      )
    end
  end

  context "stdlib reference with root scope operator" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        ::String.new
      end
      RUBY
    end

    it "infers the namespace reference clue" do
      expect(application.symbols.find_reference_to("String")).to have_attributes(
        clues: [
          have_attributes(
            itself: be_a(::Question::Ruby::TypeInference::Clue::NamespaceReference),
            name: "String",
            resolution_possibilities: ["::"]
          )
        ]
      )
    end
  end
end
