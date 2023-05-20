# frozen_string_literal: true

require_relative "support/snippet_parser"

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "duplicated module declaration" do
    let(:code) do
      <<-RUBY
      module MyApp
        module MyModule
          Foo1.bar()
        end

        module MyModule
          Foo2.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo1")).to have_attributes(
        resolution: ["MyApp::MyModule", "MyApp"]
      )

      expect(application.references.find("Foo2")).to have_attributes(
        resolution: ["MyApp::MyModule", "MyApp"]
      )
    end
  end
end
