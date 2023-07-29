# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::ResolveConstant do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      module Calculator
        Number = ::Data.define(:value)

        class Operation
          class Sum; end
        end
      end

      module Controller
      end
    end
    RUBY
  end

  context "when referencing itself" do
    it "resolves the scope" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Operation")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new("Operation")

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be(scope)
    end
  end

  context "when referencing a sibling" do
    it "resolves the scope" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Number")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new("Operation")

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be(application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Operation"))
    end
  end

  context "when referencing the child of a sibling" do
    it "resolves the scope" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Number")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new(["Operation", "Sum"])

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be(application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Operation::Sum"))
    end
  end

  context "when referencing a child scope" do
    it "resolves the scope" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Calculator")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new(["Operation", "Sum"])

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be(application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Operation::Sum"))
    end
  end

  context "when referencing a constant from another using root scope operator" do
    it "returns nil" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Controller")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new(["MyApp", "Calculator", "Operation", "Sum"])
      constant_nesting_syntax.mark_as_root_scope!

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be(application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Operation::Sum"))
    end
  end

  context "when referencing a constant from another namespace without the parent namespace" do
    it "returns nil" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Controller")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new(["Operation", "Sum"])

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be_nil
    end
  end

  context "when referencing a non existing constant" do
    it "returns nil" do
      scope = application.scopes.find_by_fully_qualified_name("::MyApp::Calculator::Number")
      constant_nesting_syntax = ::Holistic::Ruby::Parser::NestingSyntax.new("NonExisting")

      resolved_scope = described_class.call(scope:, constant_nesting_syntax:)

      expect(resolved_scope).to be_nil
    end
  end
end
