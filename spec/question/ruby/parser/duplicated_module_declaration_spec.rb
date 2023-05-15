# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

  context "duplicated module declaration" do
    let(:code) do
      <<-RUBY
      module MyApp
        module MyModule
          Foo1.bar()
        end

        module MyModule
          Foo2.bar()
        end
      end
      RUBY
    end

    it "parses the code" do
      references = detect_references(code)

      expect(references.find("Foo1")).to have_attributes(
        resolution: ["MyApp::MyModule", "MyApp"]
      )

      expect(references.find("Foo2")).to have_attributes(
        resolution: ["MyApp::MyModule", "MyApp"]
      )
    end
  end
end
