# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

  context "module declaration in the root namespace" do
    let(:code) do
      <<-RUBY
      module MyModule
        Foo.bar()
      end
      RUBY
    end

    it "parses the code" do
      references = detect_references(code)

      expect(references.find("Foo")).to have_attributes(
        namespace: have_attributes(name: "MyModule")
      )
    end
  end
end
