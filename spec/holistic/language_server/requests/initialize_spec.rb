# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Initialize do
  let(:message) do
    ::Holistic::LanguageServer::Message.new(::JSON.parse(::File.read("spec/fixtures/language_server_initialize_message.json")))
  end

  after do
    ::Holistic::Ruby::Application::Repository.delete_all
  end

  it "registers an application on the root directory" do
    expect(::Holistic::Ruby::Application::Repository.list_all.size).to be(0)

    described_class.call(message)

    expect(::Holistic::Ruby::Application::Repository.list_all.size).to be(1)
  end

  it "returns a response with the Holistic capabilities"
end
