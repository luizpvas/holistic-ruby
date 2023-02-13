# frozen_string_literal: true

describe ::Question::Ruby::Parse::Source do
  describe "single module in the global namespace" do
    subject(:parse_source) { described_class.call(application:, source:) }

    let(:application) { ::Question::Ruby::Application.new }

    let(:source) do
      <<-RUBY
      module MyModule
        Name.foo()
      end
      RUBY
    end

    it "finishes the parsing process in global namespace" do
      parse_source

      expect(application.constant_registry.namespace.global?).to be(true)
    end

    it "stores a constant reference for `Name`" do
      parse_source

      references = application.constant_registry.references

      expect(references.size).to eql(1)
      expect(references.first.name).to eql("Name")
      expect(references.first.namespace.name).to eql("MyModule")
    end
  end

  describe "single module declared with the path syntax in the global namespace" do
    subject(:parse_source) { described_class.call(application:, source:) }

    let(:application) { ::Question::Ruby::Application.new }

    let(:source) do
      <<-RUBY
      module MyApp::MyModule
        Name.foo()
      end
      RUBY
    end

    it "finishes the parsing process in global namespace" do
      parse_source

      expect(application.constant_registry.namespace.global?).to be(true)
    end

    it "stores a constant reference for `Name`" do
      parse_source

      references = application.constant_registry.references

      expect(references.size).to eql(1)
      expect(references.first.name).to eql("Name")
      expect(references.first.namespace.name).to eql("MyApp::MyModule")
    end
  end
end
