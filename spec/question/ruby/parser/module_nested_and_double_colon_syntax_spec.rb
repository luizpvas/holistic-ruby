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
        resolution: ["MyApp::MyModule1::MyModule2", "MyApp"]
      )
    end
  end
end
