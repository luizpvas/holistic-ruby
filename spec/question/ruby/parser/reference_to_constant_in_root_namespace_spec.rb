# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  include SnippetParser

  context "reference to constant in root namespace" do
    let(:application) do
      parse_snippet <<-RUBY
      module MyApp
        class MyClass < ::MyParentClass; end
      end
      RUBY
    end

    it "parses the code" do
      expect(application.references.find("MyParentClass")).to have_attributes(
        resolution: []
      )
    end
  end
end
