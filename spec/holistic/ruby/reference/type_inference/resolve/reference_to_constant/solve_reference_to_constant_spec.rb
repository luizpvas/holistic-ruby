# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued do
  include ::Support::SnippetParser

  context "when solving reference to constant in rspec suite" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        VALUE = "value"
      end

      describe MyApp do
        it "has value" do
          expect(::MyApp::VALUE).to eq("value")
        end
      end
      RUBY
    end

    it "resolves the reference to the constant" do
      reference = application.references.find_by_code_content("::MyApp::VALUE")

      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyApp::VALUE")
    end
  end
end
