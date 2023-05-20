# frozen_string_literal: true

require_relative "support/snippet_parser"

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "module declaration with nested syntax AND double colon syntax" do
    let(:code) do
      <<-RUBY
      module MyApp
        module MyModule1::MyModule2
          Name.foo()
        end
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Name")).to have_attributes(
        resolution: ["MyApp::MyModule1::MyModule2", "MyApp"]
      )
    end
  end
end
