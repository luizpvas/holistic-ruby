# frozen_string_literal: true

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
