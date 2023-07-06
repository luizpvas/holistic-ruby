# frozen_string_literal: true

describe ::Holistic::Database::Table do
  let(:table) do
    described_class.new(indices: [:color])
  end

  describe "#insert" do
    it "inserts the record" do
      expect(table.size).to be(0)

      table.insert({ identifier: "example" })

      expect(table.size).to be(1)
    end

    it "inserts multiple records" do
      expect(table.size).to be(0)

      table.insert({ identifier: "example1" })
      table.insert({ identifier: "example2" })
      table.insert({ identifier: "example3" })
      
      expect(table.size).to be(3)
    end

    it "inserts an entry for each indexed attribute" do
      record = { identifier: "example", color: "green" }

      table.insert(record)

      expect(table.primary_index).to include("example")
      expect(table.secondary_indices[:color]).to include("green")

      expect(table.find("example")).to eql(record)
      expect(table.filter(:color, "green")).to eql([record])
    end

    it "inserts multiple entries in the index if value is an array" do
      record = { identifier: "example", color: ["green", "blue"] }

      table.insert(record)

      expect(table.secondary_indices[:color]).to include("green")
      expect(table.secondary_indices[:color]).to include("blue")

      expect(table.filter(:color, "green")).to eql([record])
      expect(table.filter(:color, "blue")).to eql([record])
    end

    context "when record does not have a primary key" do
      it "raises an error" do
        expect { table.insert({}) }.to raise_error(::KeyError)
      end
    end

    context "when record with the same primary key already exists" do
      it "raises an error" do
        table.insert({ identifier: "example" })

        expect { table.insert({ identifier: "example" }) }.to raise_error(described_class::RecordNotUniqueError)
      end
    end
  end

  describe "#update" do
    context "when record does not exist" do
      it "inserts the record" do
        record = { identifier: "example", color: "green" }

        table.update(record)

        expect(table.find("example")).to eql(record)
        expect(table.filter(:color, "green")).to eql([record])
      end
    end

    context "when record already exists" do
      it "updates all indices with the new data" do
        table.insert({ identifier: "example", color: "green" })
        table.update({ identifier: "example", color: ["green", "blue"] })

        expect(table.size).to be(1)

        expect(table.find("example")).to eql({ identifier: "example", color: ["green", "blue"] })
      end
    end
  end

  describe "#delete" do
    context "when record exists" do
      it "returns the deleted data" do
        table.insert({ identifier: "example" })

        result = table.delete("example")

        expect(result).to eql({ identifier: "example" })

        result = table.delete("example")

        expect(result).to be_nil

        expect(table.size).to be(0)
      end

      it "deletes the record from all indices" do
        table.insert({ identifier: "example", color: "green" })
        table.delete("example")

        expect(table.primary_index).to be_empty
        expect(table.secondary_indices[:color]).to be_empty
      end

      it "deletes the record from all indices when value is an array" do
        table.insert({ identifier: "example", color: ["green", "blue"] })
        table.delete("example")

        expect(table.primary_index).to be_empty
        expect(table.secondary_indices[:color]).to be_empty
      end
    end

    context "when record does not exist" do
      it "returns nil" do
        result = table.delete("non-existing-primary-key")

        expect(result).to be_nil
      end
    end
  end
end
