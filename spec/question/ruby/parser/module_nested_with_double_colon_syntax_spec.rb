# frozen_string_literal: true

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

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyApp" => {
            "MyModule" => {}
          }
        }
      })
    end
  end
end
