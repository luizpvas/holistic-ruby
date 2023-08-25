# frozen_string_literal: true

describe ::Holistic::Database::Table do
  let(:table) do
    described_class.new(primary_attribute: :identifier, indices: [:color])
  end

  describe "#store" do
    it "inserts a new record if it does not exist" do
      expect(table.size).to be(0)

      table.store({ identifier: "example" })

      expect(table.size).to be(1)
    end

    it "inserts multiple records" do
      expect(table.size).to be(0)

      table.store({ identifier: "example1" })
      table.store({ identifier: "example2" })
      table.store({ identifier: "example3" })
      
      expect(table.size).to be(3)
    end

    it "inserts an entry for each indexed attribute" do
      record = { identifier: "example", color: "green" }

      table.store(record)

      expect(table.primary_index).to include("example")
      expect(table.secondary_indices[:color]).to include("green")

      expect(table.find("example")).to eql(record)
      expect(table.filter(:color, "green")).to eql([record])
    end

    it "indexes multiple values if attribute is an array" do
      record = { identifier: "example", color: ["green", "blue"] }

      table.store(record)

      expect(table.secondary_indices[:color]).to include("green")
      expect(table.secondary_indices[:color]).to include("blue")

      expect(table.filter(:color, "green")).to eql([record])
      expect(table.filter(:color, "blue")).to eql([record])
    end

    context "when the primary key is not present in the record attributes" do
      it "raises an error" do
        expect { table.store({}) }.to raise_error(::KeyError)
      end
    end

    context "when a record with the same primary key already exists" do
      it "updates all indices with the new data" do
        record = { identifier: "example", color: "green" }

        table.store(record)

        record = record.dup
        record[:color] = ["green", "blue"]

        table.store(record)

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
        table.store({ identifier: "example" })

        result = table.delete("example")

        expect(result).to eql({ identifier: "example" })

        result = table.delete("example")

        expect(result).to be_nil

        expect(table.size).to be(0)
      end

      it "deletes the record from all indices" do
        table.store({ identifier: "example", color: "green" })
        table.delete("example")

        expect(table.primary_index).to be_empty
        expect(table.secondary_indices[:color]).to be_empty
      end

      it "deletes the record from all indices when value is an array" do
        table.store({ identifier: "example", color: ["green", "blue"] })
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
