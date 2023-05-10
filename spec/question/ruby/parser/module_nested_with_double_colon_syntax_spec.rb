# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

  context "nested module declaration with double colon syntax" do
    let(:code) do
      <<-RUBY
      module MyApp::MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      references = detect_references(code)

      expect(references.find("Foo")).to have_attributes(
        namespace: have_attributes(kind: :module, name: "MyApp::MyModule")
      )
    end
  end
end
