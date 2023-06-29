# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::ReadSourceCode do
  include SnippetParser

  context "when symbol exists and has a single source location" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyApp
          module MyModule; end
        end
      RUBY
    end

    it "returns the source" do
      result = described_class.call(application:, symbol_identifier: "::MyApp::MyModule")

      expect(result).to have_attributes(
        file: have_attributes(
          itself: be_a(::Holistic::File::Fake),
          path: "snippet.rb",
        ),
        start_line: 1,
        end_line: 1
      )
    end
  end

  context "when file_path is specified as argument" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyApp
          module MyModule; end
        end
      RUBY
    end

    it "returns the source" do
      result = described_class.call(application:, file_path: "snippet.rb")

      expect(result).to have_attributes(
        file: have_attributes(
          itself: be_a(::Holistic::File::Fake),
          path: "snippet.rb",
        )
      )
    end
  end

  context "when symbol exists and has multiple source locations"
  context "when symbol does not exist"
end
