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
      my_app_before = application.symbol_index.find("::MyApp")
      my_app_example_before = application.symbol_index.find("::MyApp::Example")

      described_class.call(application:, file: application.files.find("snippet.rb"))

      my_app_after = application.symbol_index.find("::MyApp")
      my_app_example_after = application.symbol_index.find("::MyApp::Example")

      expect(my_app_before.identifier).to eql(my_app_after.identifier)
      expect(my_app_before).not_to be(my_app_after)

      expect(my_app_example_before.identifier).to eql(my_app_example_after.identifier)
      expect(my_app_example_before).not_to be(my_app_example_after)
    end
  end

  context "when file content is different" do
    let(:application) do
      parse_snippet <<~RUBY
        module MyApp
          module Example1; end
        end
      RUBY
    end

    let(:new_source_code) do
      <<~RUBY
      module MyApp
        module Example2; end
      end
      RUBY
    end

    before do
      expect(application.files.find("snippet.rb"))
        .to receive(:read)
        .and_return(new_source_code)
    end

    it "deletes symbols from previous content and parses new ones" do
      my_app_before = application.symbol_index.find("::MyApp")
      my_app_example_1_before = application.symbol_index.find("::MyApp::Example1")
      my_app_example_2_before = application.symbol_index.find("::MyApp::Example2")

      described_class.call(application:, file: application.files.find("snippet.rb"))

      my_app_after = application.symbol_index.find("::MyApp")
      my_app_example_1_after = application.symbol_index.find("::MyApp::Example1")
      my_app_example_2_after = application.symbol_index.find("::MyApp::Example2")

      expect(my_app_before.identifier).to eql(my_app_after.identifier)
      expect(my_app_before).not_to be(my_app_after)

      expect(my_app_example_1_before).to be_a(::Question::Ruby::Symbol::Record)
      expect(my_app_example_1_after).to be_nil

      expect(my_app_example_2_before).to be_nil
      expect(my_app_example_2_after).to be_a(::Question::Ruby::Symbol::Record)
    end
  end
end