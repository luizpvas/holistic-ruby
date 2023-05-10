# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

  context "module declaration with nested syntax" do
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
      references = detect_references(code)

      expect(references.find("Foo")).to have_attributes(
        namespace: have_attributes(
          name: "MyModule",
          parent: have_attributes(
            name: "MyApp"
          )
        )
      )
    end
  end
end
