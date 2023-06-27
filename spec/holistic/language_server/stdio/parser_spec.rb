# frozen_string_literal: true

describe ::Holistic::LanguageServer::Stdio::Parser do
  context "when input contains valid JSON in a single payload" do
    let(:parser) { described_class.new }

    it "completes the parser successfully" do
      encoded_message = { "message" => "ok" }.to_json

      payload = "Content-Length: #{encoded_message.length}\r\n\r\n#{encoded_message}"

      parser.ingest(payload)

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({ "message" => "ok" })
      expect(parser.has_left_over?).to be(false)
    end
  end

  context "when input contains valid JSON split into multiple payloads" do
    let(:parser) { described_class.new }

    it "parses the message successfully" do
      encoded_message = { "message" => "ok" }.to_json

      payloads = [
        "Content-Length:",
        encoded_message.length.to_s,
        "\r\n\r\n",
        encoded_message
      ]

      payloads.each { parser.ingest(_1) }

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({ "message" => "ok" })
      expect(parser.has_left_over?).to be(false)
    end
  end

  context "when the same parser instance is used to parse multiple messages" do
    let(:parser) { described_class.new }

    let(:encoded_messages) {
      [
        { "message" => "ok" }.to_json,
        { "another_message" => "also ok" }.to_json,
        { "another_big_message" => ::SecureRandom.hex * 10 }.to_json
      ]
    }

    it "parses all messages successfully" do
      encoded_messages.each do |encoded_message|
        parser.ingest("Content-Length: #{encoded_message.length}\r\n\r\n#{encoded_message}")

        expect(parser.completed?).to be(true)
        expect(parser.message.data).to eql(::JSON.parse(encoded_message))
        expect(parser.has_left_over?).to be(false)

        parser.clear
      end
    end
  end

  context "when input contains a little bit of the next message" do
    let(:parser) { described_class.new }

    let(:payloads) do
      [
        "Content-Length: 2\r\n\r\n{}Content-Len", # 1st payload contains the beginning of the next message
        "gth: 2\r\n\r\n{}"
      ]
    end

    it "parses both messages successfully" do
      parser.ingest(payloads[0])

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({})
      expect(parser.has_left_over?).to be(true)

      parser.clear

      expect(parser.completed?).to be(false)

      parser.ingest(payloads[1])

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({})
      expect(parser.has_left_over?).to be(false)
    end
  end

  context "when input contains two full messages" do
    let(:parser) { described_class.new }

    it "parses both messages successfully" do
      payload = "Content-Length: 2\r\n\r\n{}Content-Length: 2\r\n\r\n{}"

      parser.ingest(payload)

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({})
      expect(parser.has_left_over?).to be(true)

      parser.clear

      expect(parser.completed?).to be(true)
      expect(parser.message.data).to eql({})
      expect(parser.has_left_over?).to be(false)
    end
  end

  context "when input contains invalid JSON" do
    let(:parser) { described_class.new }

    it "raises an error" do
      parser.ingest("Content-Length: 3\r\n\r\nfoo")

      expect(parser.completed?).to be(true)
      expect { parser.message }.to raise_error(::JSON::ParserError)
      expect(parser.has_left_over?).to be(false)
    end
  end

  context "when input does not specificy Content-Length on the first payload" do
    let(:parser) { described_class.new }

    it "raises an error" do
      expect {
        parser.ingest("Content-Type: application/json\r\n\r\n{}")  
      }.to raise_error(described_class::MissingContentLengthHeaderError)
    end
  end
end
