# frozen_string_literal: true

describe ::Holistic::Database::Graph do
  describe "#define_connection" do
    context "when connection name is already defined" do
      it "raises an error" do
        database = described_class.new

        database.define_connection(name: :name, inverse_of: :inverse_of)

        expect { database.define_connection(name: :name, inverse_of: :inverse_of) }.to raise_error(::ArgumentError)
      end
    end

    context "when connection inverse_of is defined by another connection" do
      it "raises an error" do
        database = described_class.new

        database.define_connection(name: :name, inverse_of: :inverse_of)

        expect { database.define_connection(name: :other_name, inverse_of: :inverse_of) }.to raise_error(::ArgumentError)
      end
    end
  end

  describe "#store" do
    context "when node does not exist" do
      it "inserts a new node" do
        database = described_class.new

        node = database.store("node-1", { key: "value" })

        expect(node.id).to eql("node-1")
        expect(node[:key]).to eql("value")
        expect(node[:non_existing_key]).to be_nil
      end
    end

    context "when node already exists" do
      it "updates the existing node attributes" do
        database = described_class.new

        node = database.store("node-1", { key: "value-1" })
        database.store("node-1", { key: "value-2" })

        expect(node[:key]).to eql("value-2")
      end

      it "updates indices" do
        database = described_class.new
        database.add_index(:color)

        node = database.store("node-1", { key: "value-1", color: "red" })

        expect(database.filter(:color, "red")).to eql([node])

        database.store("node-1", { key: "value-1", color: "blue" })

        expect(database.filter(:color, "red")).to eql([])
        expect(database.filter(:color, "blue")).to eql([node])
      end

      it "keeps existing relations"
    end
  end

  describe "#find" do
    context "when node does not exist" do
      it "returns nil" do
        database = described_class.new

        node = database.find("non_existing_id")

        expect(node).to be_nil
      end
    end

    context "when node exists" do
      it "returns the node" do
        database = described_class.new

        node = database.store("node", {})

        expect(database.find("node")).to be(node)
      end
    end
  end

  describe "#delete" do
    it "deletes the node from the primary index" do
      database = described_class.new

      node = database.store("node-1", {})

      expect(database.find("node-1")).to be(node)

      database.delete("node-1")

      expect(database.find("node-1")).to be_nil
    end

    it "deletes connections pointing to the deleted node" do
      database = described_class.new

      parent = database.store("parent", { key: "value" })
      child  = database.store("child", { key: "value" })

      database.define_connection(name: :contains, inverse_of: :belongs)
      database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs)

      database.delete("child")

      expect(database.find("child")).to be_nil
      expect(parent.connection(:contains)).to be_empty
    end
  end

  describe "#connect" do
    context "when a connection between two nodes do not exist" do
      it "stores the connection" do
        database = described_class.new

        parent = database.store("parent-1", { key: "value" })
        child  = database.store("child-1", { key: "value" })

        database.define_connection(name: :contains, inverse_of: :belongs)
        database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs)

        expect(parent.connection(:contains).to_a).to eql([child])
        expect(child.connection(:belongs).to_a).to eql([parent])
      end
    end

    context "when a connection between two nodes already exist" do
      it "does not duplicate connections" do
        database = described_class.new

        parent = database.store("parent-1", { key: "value" })
        child  = database.store("child-1", { key: "value" })

        database.define_connection(name: :contains, inverse_of: :belongs)
        database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs)
        database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs)

        expect(parent.connection(:contains).to_a).to eql([child])
        expect(child.connection(:belongs).to_a).to eql([parent])
      end
    end

    context "when referencing multiple nodes in the same connection" do
      it "adds the node to the collection" do
        database = described_class.new

        parent  = database.store("parent-1", { key: "value" })
        child_1 = database.store("child-1", { key: "value" })
        child_2 = database.store("child-2", { key: "value" })

        database.define_connection(name: :contains, inverse_of: :belongs)
        database.connect(source: parent, target: child_1, name: :contains, inverse_of: :belongs)
        database.connect(source: parent, target: child_2, name: :contains, inverse_of: :belongs)

        expect(parent.connection(:contains).to_a).to eql([child_1, child_2])
        expect(child_1.connection(:belongs).to_a).to eql([parent])
        expect(child_2.connection(:belongs).to_a).to eql([parent])
      end
    end

    context "when connection was not defined previous to the connect call" do
      it "raises an error" do
        database = described_class.new

        parent  = database.store("parent", { key: "value" })
        child = database.store("child", { key: "value" })

        expect { database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs) }.to raise_error(::ArgumentError)
      end
    end
  end

  describe "#belongs_to" do
    it "raises an error if the connection does not exist" do
      database = described_class.new

      node = database.store("node", {})

      expect { node.belongs_to(:something) }.to raise_error(::ArgumentError)
    end

    it "raises an error if the connection references multiple nodes" do
      database = described_class.new

      parent  = database.store("parent-1", { key: "value" })
      child_1 = database.store("child-1", { key: "value" })
      child_2 = database.store("child-2", { key: "value" })

      database.define_connection(name: :contains, inverse_of: :belongs)
      database.connect(source: parent, target: child_1, name: :contains, inverse_of: :belongs)
      database.connect(source: parent, target: child_2, name: :contains, inverse_of: :belongs)

      expect { parent.belongs_to(:contains) }.to raise_error(::ArgumentError)
    end

    it "returns the related node if the connection references one node" do
      database = described_class.new

      parent  = database.store("parent-1", { key: "value" })
      child = database.store("child-1", { key: "value" })

      database.define_connection(name: :contains, inverse_of: :belongs)
      database.connect(source: parent, target: child, name: :contains, inverse_of: :belongs)

      expect(child.belongs_to(:belongs)).to be(parent)
    end
  end
end
