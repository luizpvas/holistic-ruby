# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "nested class declaration with double colon syntax" do
    let(:code) do
      <<-RUBY
      class MyApp::MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo")).to have_attributes(
        resolution: ["MyApp::MyClass"]
      )
    end
  end
end
