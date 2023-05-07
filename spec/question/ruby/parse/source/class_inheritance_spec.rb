# frozen_string_literal: true

require_relative "support/parse_source_code"

describe ::Question::Ruby::Parse::Source do
  include ParseSourceCode

  describe "class inheritance without scope resolution operator" do
    let(:source_code) do
      <<-RUBY
        module MyModule
          class MySubClass < MyParentClass; end
        end
      RUBY
    end

    it "stores a reference to the parent class" do
      references = detect_references(source_code)

      expect(references.size).to eql(1)

      expect(references.first).to have_attributes(
        name: "MyParentClass",
        namespace: have_attributes(
          name: "MyModule"
        )
      )
    end
  end
end
