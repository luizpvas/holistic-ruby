# frozen_string_literal: true

require "spec_helper"

describe Holistic::Ruby::Scope::Crawler do
  include ::Support::SnippetParser

  describe "#ancestors" do
    let(:application) do
      parse_snippet <<~RUBY
      module Mod1; end
      module Mod2; include Mod1; end

      module Mod3; end
      module Mod4; end

      class Grandparent; include Mod4; end
      class Parent < Grandparent; end
      class Child < Parent
        include Mod2
        include Mod3
        include dynamically_built_mod("foo") # ignored

        def instance_child_method
        end

        def self.class_child_method
        end
      end
      RUBY
    end

    context "when scope is a class" do
      it "identifies ancestors of the scope" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child"))

        ancestors_names = crawler.ancestors.map { _1.fully_qualified_name }

        expect(ancestors_names).to eql([
          "::Child",
          "::Mod2",
          "::Mod1",
          "::Mod3",
          "::Parent",
          "::Grandparent",
          "::Mod4"
        ])
      end
    end

    context "when scope is an instance method" do
      it "identifies ancestors of the surrounding class" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child#instance_child_method"))

        ancestors_names = crawler.ancestors.map { _1.fully_qualified_name }

        expect(ancestors_names).to eql([
          "::Child",
          "::Mod2",
          "::Mod1",
          "::Mod3",
          "::Parent",
          "::Grandparent",
          "::Mod4"
        ])
      end
    end

    context "when scope is a class method" do
      it "identifies ancestors of the surrounding class" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Child.class_child_method"))

        ancestors_names = crawler.ancestors.map { _1.fully_qualified_name }

        expect(ancestors_names).to eql([
          "::Child",
          "::Mod2",
          "::Mod1",
          "::Mod3",
          "::Parent",
          "::Grandparent",
          "::Mod4"
        ])
      end
    end

    context "when scope is a module" do
      it "identifies ancestors of the surrounding class" do
        crawler = described_class.new(application:, scope: application.scopes.find("::Mod2"))

        ancestors_names = crawler.ancestors.map { _1.fully_qualified_name }

        expect(ancestors_names).to eql(["::Mod2", "::Mod1"])
      end
    end
  end
end

