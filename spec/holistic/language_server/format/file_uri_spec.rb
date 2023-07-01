# frozen_string_literal: true

describe ::Holistic::LanguageServer::Format::FileUri do
  describe ".extract_path" do
    context "when uri is valid" do
      it "returns the file path" do
        extracted_path = described_class.extract_path("file:///my_app/example.rb")

        expect(extracted_path).to eql("/my_app/example.rb")
      end
    end

    context "when uri is invalid" do
      it "returns nil" do
        extracted_path = described_class.extract_path("invalid-uri")

        expect(extracted_path).to be_nil
      end
    end
  end
end
