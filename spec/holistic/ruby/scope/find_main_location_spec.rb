# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::FindMainLocation do
  context "when scope only has one location" do
    let(:scope) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::CLASS,
        name: "MyClass",
        parent: nil,
        location: ::Holistic::Document::Location.beginning_of_file("/my_app/my_class.rb")
      )
    end

    it "returns the location" do
      main_location = described_class.call(scope:)

      expect(main_location.file_path).to eql("/my_app/my_class.rb")
    end
  end

  context "when scope has multiple locations" do
    let(:scope) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::CLASS,
        name: "MyClass",
        parent: nil
      ).tap do |scope|
        scope.locations << ::Holistic::Document::Location.beginning_of_file("/my_app/my_class.rb")
        scope.locations << ::Holistic::Document::Location.beginning_of_file("/my_app/my_class/other_class.rb")
      end
    end

    it "returns the location matching the scope name" do
      main_location = described_class.call(scope:)

      expect(main_location.file_path).to eql("/my_app/my_class.rb")
    end
  end
end
