# frozen_string_literal: true

require_relative "support/detect_references"

describe ::Question::Ruby::Parser do
  include DetectReferences

  describe "class inheritance without scope resolution operator" do
    let(:code) do
      <<-RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "stores a reference to the parent class" do
      references = detect_references(code)

      expect(references.find("MyParentClass")).to have_attributes(
        resolution: ["MyModule"]
      )
    end
  end
end
