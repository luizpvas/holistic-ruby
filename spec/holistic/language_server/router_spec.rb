# frozen_string_literal: true

describe ::Holistic::LanguageServer::Router do
  context "when routing 'initialize' messages" do
    let(:initialize_request) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 1,
        "jsonrpc" => "2.0",
        "method" => "initialize",
        "params" => { "capabilities" => {} }
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Initialize).to receive(:call).with(initialize_request)

      described_class.dispatch(initialize_request)
    end
  end
  
  context "when routing 'shutdown' requests" do
    let(:shutdown_request) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 2,
        "jsonrpc" => "2.0",
        "method" => "shutdown",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Shutdown).to receive(:call).with(shutdown_request)

      described_class.dispatch(shutdown_request)
    end
  end

  context "when routing 'exit' notifications" do
    let(:exit_notification) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "exit",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Exit).to receive(:call).with(exit_notification)

      described_class.dispatch(exit_notification)
    end
  end

  context "when routing 'textDocument/declaration' messages" do
    let(:go_to_declaration_request) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/declaration",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::GoToDeclaration).to receive(:call).with(go_to_declaration_request)

      described_class.dispatch(go_to_declaration_request)
    end
  end

  context "when routing unknown messages" do
    let(:unknown_message) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 2,
        "jsonrpc" => "2.0",
        "method" => "unknown",
        "params" => {}
      })
    end

    it "returns a response with :not_found" do
      response = described_class.dispatch(unknown_message)

      expect(response).to be_a(::Holistic::LanguageServer::Response::NotFound)
    end
  end
end
