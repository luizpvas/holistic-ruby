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
        namespace: have_attributes(name: "MyModule")
      )

      expect(references.find("Foo2")).to have_attributes(
        namespace: have_attributes(name: "MyModule")
      )

      expect(references.find("Foo1").namespace).to be(references.find("Foo2").namespace)

      expect(references.find("Foo1").namespace.source_locations.size).to be(2)
    end
  end
end
