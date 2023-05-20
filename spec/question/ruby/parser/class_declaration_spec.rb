# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "class declaration in the root namespace" do
    let(:code) do
      <<-RUBY
      class MyClass
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo")).to have_attributes(
        resolution: ["MyClass"]
      )
    end
  end
end
