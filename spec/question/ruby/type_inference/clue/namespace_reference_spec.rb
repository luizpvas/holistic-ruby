# frozen_string_literal: true

describe ::Question::Ruby::TypeInference::Clue::NamespaceReference do
  include ::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      Example.call
    end
    RUBY
  end

  it "infers the namespace reference" do
    raise "todo"
  end
end
