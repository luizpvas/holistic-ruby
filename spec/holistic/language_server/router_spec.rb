# frozen_string_literal: true

describe ::Holistic::LanguageServer::Router do
  context "when routing 'initialize' messages" do
    let(:initialize_message) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 1,
        "jsonrpc" => "2.0",
        "method" => "initialize",
        "params" => { "capabilities" => {} }
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Lifecycle::Initialize)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: initialize_message
          )
        )

      described_class.dispatch(initialize_message)
    end
  end
  
  context "when routing 'shutdown' requests" do
    let(:shutdown_message) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 2,
        "jsonrpc" => "2.0",
        "method" => "shutdown",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Lifecycle::Shutdown)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: shutdown_message
          )
        )

      described_class.dispatch(shutdown_message)
    end
  end

  context "when routing 'exit' notifications" do
    let(:exit_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "exit",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Lifecycle::Exit)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: exit_message
          )
        )

      described_class.dispatch(exit_message)
    end
  end

  context "when routing 'textDocument/definition' messages" do
    let(:go_to_definition_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/definition",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::TextDocument::GoToDefinition)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: go_to_definition_message
          )
        )

      described_class.dispatch(go_to_definition_message)
    end
  end

  context "when routing 'textDocument/didOpen' messages" do
    let(:did_open_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/didOpen",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::TextDocument::DidOpen)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: did_open_message
          )
        )

      described_class.dispatch(did_open_message)
    end
  end

  context "when routing 'textDocument/didChange' messages" do
    let(:did_change_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/didChange",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::TextDocument::DidChange)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: did_change_message
          )
        )

      described_class.dispatch(did_change_message)
    end
  end

  context "when routing 'textDocument/didSave' messages" do
    let(:did_save_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/didSave",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::TextDocument::DidSave)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: did_save_message
          )
        )

      described_class.dispatch(did_save_message)
    end
  end

  context "when routing 'textDocument/didClose' messages" do
    let(:did_close_message) do
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "textDocument/didClose",
        "params" => {}
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::TextDocument::DidClose)
        .to receive(:call)
        .with(
          have_attributes(
            itself: ::Holistic::LanguageServer::Request,
            message: did_close_message
          )
        )

      described_class.dispatch(did_close_message)
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
