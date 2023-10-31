# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Autocompletion::PieceOfCode do
  concerning :Helpers do
    def code(value)
      described_class.new(value)
    end
  end

  describe "#root_scope?" do
    it "returns true if code starts with root scope operator, false otherwise" do
      examples = [
        { code: "::",            expected: true },
        { code: "::Foo",         expected: true },
        { code: "::Foo.bar",     expected: true },
        { code: "::Foo.bar.qux", expected: true },
        { code: "::Foo::Bar",    expected: true },
        { code: "Foo",           expected: false },
        { code: "Foo::Bar",      expected: false },
        { code: "Foo.bar",       expected: false },
        { code: "bar.qux",       expected: false },
        { code: "Foo::Bar.qux",  expected: false }
      ]

      examples.each do |example|
        expect(code(example[:code]).root_scope?).to(
          eql(example[:expected]),
          "#{example[:code]}.root_scope? = #{example[:expected]}"
        )
      end
    end
  end
describe "#suggest_methods_from_current_scope?" do
    it "returns true for local method calls, false otherwise" do
      examples = [
        { code: "foo",       expected: true },
        { code: "foo.bar",   expected: true },
        { code: "foo(",      expected: true },
        { code: "Success(",  expected: true },
        { code: "Foo.bar",   expected: false },
        { code: "::Foo.bar", expected: false },
        { code: "Foo::Bar",  expected: false },
        { code: "Foo.bar(",  expected: false }
      ]

      examples.each do |example|
        expect(code(example[:code]).suggest_methods_from_current_scope?).to(
          eql(example[:expected]),
          "#{example[:code]}.suggest_methods_from_current_scope? = #{example[:expected]}"
        )
      end
    end
  end

  describe "#suggest_methods_from_scope?" do
    it "returns true for method calls on other scopes, false otherwise" do
      examples = [
        { code: "Foo.bar",      expected: true },
        { code: "Foo::Bar.qux", expected: true },
        { code: "Foo.Success",  expected: true },
        { code: "::Foo.bar",    expected: true },
        { code: "::Foo",        expected: false },
        { code: "foo",          expected: false },
        { code: "::",           expected: false }
      ]

      examples.each do |example|
        expect(code(example[:code]).suggest_methods_from_scope?).to(
          eql(example[:expected]),
          "#{example[:code]}.suggest_methods_from_scope? = #{example[:expected]}"
        )
      end
    end
  end

  describe "#suggest_namespaces?" do
    it "returns true for scopes, false otherwise" do
      examples = [
        { code: "::Foo",          expected: true },
        { code: "::Foo::",        expected: true },
        { code: "::Foo::Bar",     expected: true },
        { code: "Foo",            expected: true },
        { code: "Foo.bar",        expected: false },
        { code: "foo",            expected: false },
        { code: "::Foo::Bar.qux", expected: false },
        { code: "::Foo.",         expected: false }
      ]

      examples.each do |example|
        expect(code(example[:code]).suggest_namespaces?).to(
          eql(example[:expected]),
          "#{example[:code]}.suggest_namespaces? = #{example[:expected]}"
        )
      end
    end
  end

  describe "#namespaces" do
    it "returns the list of complete namespaces present in the code" do
      examples = [
        { code: "Foo::Bar",        expected: ["Foo"] },
        { code: "::Foo::Bar",      expected: ["Foo"] },
        { code: "::Foo::Bar::Qux", expected: ["Foo", "Bar"] },
        { code: "::Foo::Bar.qux",  expected: ["Foo", "Bar"] },
        { code: "::Foo::Bar:",     expected: ["Foo", "Bar"] },
        { code: "::Foo::Bar::",    expected: ["Foo", "Bar"] },
        { code: "::Foo::Bar.",     expected: ["Foo", "Bar"] },
        { code: "Foo::",           expected: ["Foo"] },
        { code: "Foo.",            expected: ["Foo"] },
        { code: "::",              expected: [] },
        { code: "Foo",             expected: [] },
        { code: "foo",             expected: [] },
        { code: "foo.bar",         expected: [] }
      ]

      examples.each do |example|
        namespaces = code(example[:code]).namespaces

        expect(namespaces).to(
          eql(example[:expected]),
          "expected #{example[:code]} namespaces to eql #{example[:expected].inspect}, got: #{namespaces.inspect}"
        )
      end
    end
  end

  describe "#word_to_autocomplete" do
    it "returns the namespace or method name at the end of the piece of code" do
      examples = [
        { code: "Foo", expected: "Foo" },
        { code: "Foo::Bar", expected: "Bar" },
        { code: "Foo.", expected: "" },
        { code: "foo", expected: "foo" },
        { code: "Foo::Bar.qux", expected: "qux" },
        { code: "Foo:", expected: "" },
      ]

      examples.each do |example|
        word_to_autocomplete = code(example[:code]).word_to_autocomplete

        expect(word_to_autocomplete).to(
          eql(example[:expected]),
          "expected #{example[:code]} word to autocomplete to eql #{example[:expected].inspect}, got: #{word_to_autocomplete.inspect}"
        )
      end
    end
  end
end
