# frozen_string_literal: true

describe ::Question::Ruby::Constant::Namespace do
  describe ".new" do
    it "initializes the namespace with the arguments + defaults" do
      namespace = described_class.new(kind: :module, name: "MyModule", parent: nil)

      expect(namespace).to have_attributes(
        kind: :module,
        name: "MyModule",
        parent: nil,
        children: [],
        source_locations: []
      )
    end
  end

  describe "#nest" do
    context "when a namespace with the same name DOES NOT EXIST in the parent namespace" do
      it "first child" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        expect(parent.children.size).to be(0)

        child = parent.nest(kind: :module, name: "MyChild")

        expect(parent.children.size).to be(1)

        expect(child).to have_attributes(
          kind: :module,
          name: "MyChild",
          parent:
        )
      end

      it "second child" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)
        child_1 = parent.nest(kind: :module, name: "MyChild1")
        child_2 = parent.nest(kind: :module, name: "MyChild2")

        expect(parent.children.size).to be(2)

        expect(child_1).to have_attributes(
          kind: :module,
          name: "MyChild1",
          parent: parent
        )

        expect(child_2).to have_attributes(
          kind: :module,
          name: "MyChild2",
          parent: parent
        )
      end
    end

    context "when a namespace with the same name EXISTS in the parent namespace" do
      it "returns the existing namespace" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        child_1 = parent.nest(kind: :module, name: "MyChild")
        child_2 = parent.nest(kind: :module, name: "MyChild")

        expect(parent.children.size).to be(1)

        expect(child_1).to be(child_2)
      end
    end
  end
end
