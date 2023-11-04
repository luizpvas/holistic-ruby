# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Scope::Crawler do
  include ::Support::SnippetParser

  describe "#visible_scopes" do
    let(:application) do
      parse_snippet <<~RUBY
      class Parent
        def self.parent_class_method_1; end
        def self.parent_class_method_2; end

        def parent_method_1; end
        def parent_method_2; end
      end

      class Child < Parent
        def self.child_class_method_1; end
        def self.child_class_method_2; end

        def child_method_1; end
        def child_method_2; end
      end
      RUBY
    end

    context "when scope is an instance method" do
      it "lists instance methods" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child#child_method_1"))

        sibling_methods = crawler.visible_scopes.map { _1.fully_qualified_name }

        expect(sibling_methods).to eql([
          "::Child",
          "::Child#child_method_1",
          "::Child#child_method_2",
          "::Parent",
          "::Parent#parent_method_1",
          "::Parent#parent_method_2"
        ])
      end
    end

    context "when scope is a class method" do
      it "lists class methods" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child.child_class_method_1"))

        sibling_methods = crawler.visible_scopes.map { _1.fully_qualified_name }

        expect(sibling_methods).to eql([
          "::Child",
          "::Child.child_class_method_1",
          "::Child.child_class_method_2",
          "::Child.new",
          "::Parent",
          "::Parent.parent_class_method_1",
          "::Parent.parent_class_method_2",
          "::Parent.new"
        ])
      end
    end
  end
end
