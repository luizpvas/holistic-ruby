# frozen_string_literal: true

require_relative "support/snippet_parser"

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "nested module declaration" do
    let(:code) do
      <<-RUBY
      module MyApp
        module MyModule
          Foo.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo")).to have_attributes(
        resolution: ["MyApp::MyModule", "MyApp"]
      )
    end
  end
end
