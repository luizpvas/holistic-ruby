# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Scope::Crawler do
  include ::Support::SnippetParser

  describe "#lexical_parents" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        module Mod1
          module Mod3; end

          module Mod2
            class Class1
              def method
              end
            end
          end
        end
      end
      RUBY
    end

    context "when scope is an instance method" do
      it "returns lexical parents from the surrounding class upwards" do
        instance_method = application.scopes.find("::MyApp::Mod1::Mod2::Class1#method")

        crawler = described_class.new(application:, scope: instance_method)

        lexical_parent_names = crawler.lexical_parents.map { _1.fully_qualified_name }

        expect(lexical_parent_names).to eql([
          "::MyApp::Mod1::Mod2::Class1",
          "::MyApp::Mod1::Mod2",
          "::MyApp::Mod1",
          "::MyApp",
          "::"
        ])
      end
    end
  end
end
