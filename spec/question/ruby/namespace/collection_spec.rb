# frozen_string_literal: true

describe ::Question::Ruby::Namespace::Collection do
  include SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module ModuleParent1::ModuleParent2
      module ModuleChild
        class ClassChild; end
      end
    end
    RUBY
  end

  describe "#find" do
    it "finds modules and classes by their fully qualified name" do
      collection = described_class.new(application.root_namespace)

      expect(collection.find("::")).to eql(application.root_namespace)

      # TODO: expect(collection.find("::ModuleParent1")).to be_truthy

      expect(collection.find("::ModuleParent1::ModuleParent2")).to be_a(
        ::Question::Ruby::Namespace::Record
      )

      expect(collection.find("::ModuleParent1::ModuleParent2::ModuleChild")).to be_a(
        ::Question::Ruby::Namespace::Record
      )

      expect(collection.find("::ModuleParent1::ModuleParent2::ModuleChild::ClassChild")).to be_a(
        ::Question::Ruby::Namespace::Record
      )
    end
  end
end
