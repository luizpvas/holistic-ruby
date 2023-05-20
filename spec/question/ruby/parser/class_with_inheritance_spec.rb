# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  describe "class inheritance without scope resolution operator" do
    let(:code) do
      <<-RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "parses the code" do
      application = parse_snippet(code)

      expect(application.references.find("MyParentClass")).to have_attributes(
        resolution: ["MyModule"]
      )

      expect(application.root_namespace.serialize).to eql({
        "::" => {
          "MyModule" => {
            "MySubClass" => {}
          }
        }
      })
    end
  end
end
