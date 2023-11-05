# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Scope::Crawler do
  include ::Support::SnippetParser

  describe "#resolve_constant" do
    let(:application) do
    parse_snippet <<~RUBY
    Const4 = "val"

    module Unrelated
      Const5 = "val"
    end

    module MyApp
      Const1 = "val"

      class Parent
        Const1 = "val"
        Const2 = "val"
        Const3 = "val"
      end

      class Child < Parent
        Const2 = "val"

        def method; end
      end
    end
    RUBY
    end

    let(:crawler) do
      scope = application.scopes.find("::MyApp::Child#method")

      described_class.new(application:, scope:)
    end

    context "when resolving a constant defined in the class and parent class" do
      it "prioritizes the class" do
        scope = crawler.resolve_constant("Const2")

        expect(scope.fully_qualified_name).to eql("::MyApp::Child::Const2")
      end
    end

    context "when resolving a constant defined in the parent class" do
      it "returns the constant from the parent class" do
        constant = crawler.resolve_constant("Const3")

        expect(constant.fully_qualified_name).to eql("::MyApp::Parent::Const3")
      end
    end

    context "when resolving a constant defined in the lexical parent and ancestor" do
      it "retunrs the constant from the lexical parent" do
        constant = crawler.resolve_constant("Const1")

        expect(constant.fully_qualified_name).to eql("::MyApp::Const1")
      end
    end

    context "when resolving a constant defined in the root scope" do
      it "returns the constant from the root scope" do
        constant = crawler.resolve_constant("Const4")

        expect(constant.fully_qualified_name).to eql("::Const4")
      end
    end

    context "when resolving a constant defined in a sibling namespace" do
      it "returns nil" do
        constant = crawler.resolve_constant("Const5")

        expect(constant).to be_nil
      end
    end
  end
end

