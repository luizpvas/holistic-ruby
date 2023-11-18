# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::TableOfContents::Store do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    class Foo; end
    RUBY
  end

  context "when scope does not have a table of contents" do
    it "inserts a record in the database" do
      scope = application.scopes.find("::Foo")

      table_of_contents = described_class.call(
        database: application.database,
        scope:,
        identifier: "url",
        type: ::Holistic::Ruby::TableOfContents::Type::Instance.new("::String")
      )

      expect(table_of_contents).to be_a(::Holistic::Ruby::TableOfContents::Record)
      expect(table_of_contents.items.keys).to eql(["url"])

      table_of_contents.items["url"].tap do |url|
        expect(url).to be_a(::Holistic::Ruby::TableOfContents::Item)
        expect(url.type).to be_a(::Holistic::Ruby::TableOfContents::Type::Instance)
        expect(url.type.fully_qualified_name).to eql("::String")
      end
    end
  end

  context "when scope already has a table of contents" do
    it "adds the item to the existing table of contents" do
      scope = application.scopes.find("::Foo")

      table_of_contents = described_class.call(
        database: application.database,
        scope:,
        identifier: "url",
        type: ::Holistic::Ruby::TableOfContents::Type::Instance.new("::String")
      )

      described_class.call(
        database: application.database,
        scope:,
        identifier: "max_retry",
        type: ::Holistic::Ruby::TableOfContents::Type::Instance.new("::Integer")
      )

      expect(table_of_contents.items.keys).to eql(["url", "max_retry"])

      table_of_contents.items["url"].tap do |url|
        expect(url.type.fully_qualified_name).to eql("::String")
      end

      table_of_contents.items["max_retry"].tap do |max_retry|
        expect(max_retry.type.fully_qualified_name).to eql("::Integer")
      end
    end
  end

  context "when scope has table of contents and identifier already exists" do
    it "overrides the existing item" do
      scope = application.scopes.find("::Foo")

      table_of_contents = described_class.call(
        database: application.database,
        scope:,
        identifier: "url",
        type: ::Holistic::Ruby::TableOfContents::Type::Instance.new("::String")
      )

      described_class.call(
        database: application.database,
        scope:,
        identifier: "url",
        type: ::Holistic::Ruby::TableOfContents::Type::Instance.new("::URL")
      )

      expect(table_of_contents.items.keys).to eql(["url"])

      table_of_contents.items["url"].tap do |url|
        expect(url.type.fully_qualified_name).to eql("::URL")
      end
    end
  end
end
