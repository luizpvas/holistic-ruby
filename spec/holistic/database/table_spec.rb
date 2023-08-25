# frozen_string_literal: true

describe ::Holistic::Database::Table do
  let(:table) do
    described_class.new(indices: [:color])
  end

  describe "#store" do
    it "inserts a new record if it does not exist" do
      expect(table.size).to be(0)

      table.store("example", {})

      expect(table.size).to be(1)
    end

    it "inserts multiple records" do
      expect(table.size).to be(0)

      table.store("example1", {})
      table.store("example2", {})
      table.store("example3", {})
      
      expect(table.size).to be(3)
    end

    it "inserts an entry for each indexed attribute" do
      record = { color: "green" }

      table.store("example", record)

      expect(table.records).to include("example")
      expect(table.indices[:color]).to include("green")

      expect(table.find("example")).to eql(record)
      expect(table.filter(:color, "green")).to eql([record])
    end

    it "indexes multiple values if attribute is an array" do
      record = { color: ["green", "blue"] }

      table.store("example", record)

      expect(table.indices[:color]).to include("green")
      expect(table.indices[:color]).to include("blue")

      expect(table.filter(:color, "green")).to eql([record])
      expect(table.filter(:color, "blue")).to eql([record])
    end

    context "when a record with the same primary key already exists" do
      it "updates all indices with the new data" do
        record = { color: "green" }

        table.store("example", record)

        record = record.dup
        record[:color] = ["green", "blue"]

        table.store("example", record)

        expect(table.size).to be(1)

        expect(table.find("example")).to eql(record)
        expect(table.filter(:color, "green")).to match_array([record])
        expect(table.filter(:color, "blue")).to match_array([record])
      end
    end
  end

  describe "#delete" do
    context "when record exists" do
      it "returns the deleted data" do
        table.store("example", {})

        table.delete("example")
        table.delete("example") # multiple calls are fine

        expect(table.size).to be(0)
      end

      it "deletes the record from all indices" do
        table.store("example", { color: "green" })
        table.delete("example")

        expect(table.records).to be_empty
        expect(table.indices[:color]).to be_empty
      end

      it "deletes the record from all indices when value is an array" do
        table.store("example", { color: ["green", "blue"] })
        table.delete("example")

        expect(table.records).to be_empty
        expect(table.indices[:color]).to be_empty
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
