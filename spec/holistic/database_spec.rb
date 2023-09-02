# frozen_string_literal: true

describe ::Holistic::Database do
  describe "#define_connection" do
    context "when connection does not exist" do
      it "stores the connection definition" do
        database = described_class.new

        database.define_connection(name: :contains, inverse_of: :belongs)

        expect(database.connections).to eql({
          contains: { inverse_of: :belongs },
          belongs: { inverse_of: :contains }
        })
      end
    end

    context "when connection's :inverse_of exists as the name of another connection" do
      it "raises an error" do
        database = described_class.new

        database.define_connection(name: :contains, inverse_of: :belongs)

        expect {
          database.define_connection(name: :another_contains, inverse_of: :belongs)
        }.to raise_error(::ArgumentError)
      end
    end

    context "when connection already exists" do
      it "raises an error" do
        database = described_class.new

        database.define_connection(name: :contains, inverse_of: :belongs)

        expect {
          database.define_connection(name: :contains, inverse_of: :another_belongs)
        }.to raise_error(::ArgumentError)
      end
    end
  end

  describe "#store" do
    context "when node does not exist" do
      it "inserts the node in the database" do
        database = described_class.new

        expect(database.size).to be(0)

        node = database.store("node", { key: "value" })

        expect(database.size).to be(1)

        expect(node.attr(:key)).to eql("value")
      end
    end

    context "when node already exists" do
      it "replaces the existing node attributes" do
        database = described_class.new

        node_1 = database.store("node", { key1: "value1" })
        node_2 = database.store("node", { key2: "value2" })

        expect(node_1).to be(node_2)

        expect(node_2.attr(:key1)).to be_nil
        expect(node_2.attr(:key2)).to eql("value2")
      end
    end

    context "when attributes are specified a kind that inherits from node" do
      class SubkindNode < ::Holistic::Database::Node
        def name = attr(:name)
      end

      it "stores the nodes as-is" do
        database = described_class.new
        
        node = SubkindNode.new("node", { name: "NODE_NAME" })

        node = database.store("node", node)

        expect(node).to be_an_instance_of(SubkindNode)
        expect(node.name).to eql("NODE_NAME")
      end

      it "sets the __database__ property on the node" do
        database = described_class.new
        
        node = SubkindNode.new("node", { name: "NODE_NAME" })

        expect(node.__database__).to be_nil

        database.store("node", node)

        expect(node.__database__).to be(database)
      end

      it "updates the node attributes if node already exists in the database" do
        database = described_class.new

        node_1 = SubkindNode.new("node", { name: "NODE_NAME" })

        node_1st_store = database.store("node", node_1)

        node_2 = SubkindNode.new("node", { name: "UPDATED_NODE_NAME" })

        node_2nd_store = database.store("node", node_2)

        expect(node_1st_store).to be(node_1)
        expect(node_2nd_store).to be(node_1)

        expect(node_1st_store.name).to eql("UPDATED_NODE_NAME")
      end
    end
  end

  describe "#connect" do
    context "when connection between the nodes does not exist" do
      it "stores the connection in both nodes" do
        database = described_class.new
        database.define_connection(name: :children, inverse_of: :parent)

        parent = database.store("parent", {})
        child = database.store("child", {})

        parent.relation(:children).add!(child)

        expect(parent.relation(:children)).to match_array([child])
        expect(child.has_one(:parent)).to eql(parent)
      end
    end

    context "when connection between the nodes already exist" do
      it "does not duplicate data" do
        database = described_class.new
        database.define_connection(name: :children, inverse_of: :parent)

        parent = database.store("parent", {})
        child = database.store("child", {})

        # calling multiple times
        parent.relation(:children).add!(child)
        parent.relation(:children).add!(child)
        parent.relation(:children).add!(child)

        expect(parent.relation(:children)).to match_array([child])
        expect(child.has_one(:parent)).to eql(parent)
      end
    end

    context "when connection was not defined" do
      it "raises an error" do
        database = described_class.new

        parent = database.store("parent", {})
        child = database.store("child", {})

        expect {
          parent.relation(:children).add!(child)
        }.to raise_error(::ArgumentError)
      end
    end
  end

  describe "#disconnect" do
    context "when connection between node exist" do
      it "deletes the connection from both nodes" do
        database = described_class.new
        database.define_connection(name: :children, inverse_of: :parent)

        parent = database.store("parent", {})
        child = database.store("child", {})

        parent.relation(:children).add!(child)
        parent.relation(:children).delete!(child)

        expect(parent.relation(:children)).to match_array([])
        expect(child.has_one(:parent)).to be_nil
      end
    end

    context "when connection between nodes does not exist" do
      it "does nothing" do
        database = described_class.new
        database.define_connection(name: :children, inverse_of: :parent)

        parent = database.store("parent", {})
        child = database.store("child", {})

        # calling disconnect without calling connect first
        parent.relation(:children).delete!(child)

        expect(parent.relation(:children)).to match_array([])
        expect(child.has_one(:parent)).to be_nil
      end
    end

    context "when connection was not defined before calling disconnect" do
      it "raises an error" do
        database = described_class.new

        parent = database.store("parent", {})
        child = database.store("child", {})

        # calling disconnect without calling `define_connection`
        expect {
          parent.relation(:children).delete!(child)
        }.to raise_error(::ArgumentError)
      end
    end
  end

  describe "#find" do
    context "when node exists in the database" do
      it "returns the node" do
        database = described_class.new

        stored_node = database.store("node", {})
        found_node  = database.find("node")

        expect(found_node).to be(stored_node)
      end
    end

    context "when node does not exist in the database" do
      it "returns nil" do
        database = described_class.new

        expect(database.find("non_existing_node")).to be_nil
      end
    end
  end

  describe "#delete" do
    context "when node exists in the database" do
      it "deletes the node from the database" do
        database = described_class.new

        stored_node = database.store("node", {})
        deleted_node = database.delete("node")

        expect(deleted_node).to be(stored_node)

        expect(database.find("node")).to be_nil
      end
    end

    context "when node does not exist in the database" do
      it "returns nil" do
        database = described_class.new

        expect(database.delete("non_existing_node")).to be_nil
      end
    end
  end
end
