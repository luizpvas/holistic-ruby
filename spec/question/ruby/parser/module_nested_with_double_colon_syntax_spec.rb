# frozen_string_literal: true

require_relative "support/snippet_parser"

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "nested module declaration with double colon syntax" do
    let(:code) do
      <<-RUBY
      module MyApp::MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo")).to have_attributes(
        resolution: ["MyApp::MyModule"]
      )
    end
  end
end
