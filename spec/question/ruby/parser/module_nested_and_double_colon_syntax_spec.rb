# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

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
      references = detect_references(code)

      expect(references.find("Name")).to have_attributes(
        namespace: have_attributes(
          kind: :module,
          name: "MyModule1::MyModule2",
          parent: have_attributes(
            kind: :module,
            name: "MyApp"
          )
        )
      )
    end
  end
end
