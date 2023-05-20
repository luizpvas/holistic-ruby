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

    it "stores a reference to the parent class" do
      application = parse_snippet(code)

      expect(application.references.find("MyParentClass")).to have_attributes(
        resolution: ["MyModule"]
      )
    end
  end
end
