# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Scope::Crawler do
  include ::Support::SnippetParser

  describe "#sibling_methods" do
    context "when scope is an instance method" do
      let(:application) do
        parse_snippet <<~RUBY
        class Parent
          def parent_method_1
          end

          def parent_method_2
          end
        end

        class Child < Parent
          def child_method_1
            # cursor here
          end

          def child_method_2
          end
        end
        RUBY
      end

      it "lists other instance methods" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child#child_method_1"))

        sibling_methods = crawler.sibling_methods.map { _1.fully_qualified_name }

        expect(sibling_methods).to eql([
          "::Child#child_method_1",
          "::Child#child_method_2",
          "::Parent#parent_method_1",
          "::Parent#parent_method_2"
        ])
      end
    end

    context "when scope is a class method"
  end
end
