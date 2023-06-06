# frozen_string_literal: true

describe ::Question::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::SnippetParser

  context "when file content did not change" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyApp
          module Example; end
        end
      RUBY
    end

    it "ends up in the same state as before the change" do
      described_class.call(application:, file_path: "snippet.rb")

      expect(application.symbol_index.find("::MyApp")).to exist
      expect(application.symbol_index.find("::MyApp::Example")).to exist
    end
  end

  context "when file content is different" do
    it "deletes symbols from previous content and parses the new one"
  end
end