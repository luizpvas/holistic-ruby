# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "module declaration in the root namespace" do
    let(:code) do
      <<-RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("Foo")).to have_attributes(
        resolution: ["MyModule"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {}
        }
      })
    end
  end
end
