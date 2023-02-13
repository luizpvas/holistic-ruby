# frozen_string_literal: true

describe ::Question::Ruby::Parse::Source do
  describe "single module in the global namespace" do
    subject(:parse_source) { described_class.call(application:, source:) }

    let(:application) { ::Question::Ruby::Application.new }

    let(:source) do
      <<-RUBY
      module MyModule
        Name = "foo"
      end
      RUBY
    end

    it "ends up in global namespace" do
      parse_source

      expect(application.constant_registry.namespace.global?).to be(true)
    end

    it "stores a constant reference for `Name`" do
      parse_source

      expect(application.constant_registry.references.size).to eql(1)
    end
  end
end
