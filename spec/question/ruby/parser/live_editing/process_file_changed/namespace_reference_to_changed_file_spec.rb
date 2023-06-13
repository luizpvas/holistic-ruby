# frozen_string_literal: true

describe ::Question::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::SnippetParser

  context "when the changed file contents remains the same" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "my_app/example_1.rb", <<~RUBY
        module MyApp
          module Example1
            def self.call; end
          end
        end
        RUBY

        files.add "my_app/example_2.rb", <<~RUBY
        module MyApp
          module Example2
            Example1.call
          end
        end
        RUBY
      end
    end

    it "ends up in the same state" do
      symbols_before = application.dependencies.list_dependants(dependency_file_path: "my_app/example_1.rb")

      expect(symbols_before.size).to eql(1)
      expect(symbols_before.first.record.conclusion).to have_attributes(symbol_identifier: "::MyApp::Example1")

      described_class.call(application:, file: application.files.find("my_app/example_1.rb"))

      symbols_after = application.dependencies.list_dependants(dependency_file_path: "my_app/example_1.rb")

      expect(symbols_after.size).to eql(1)
      expect(symbols_after.first.record.conclusion).to have_attributes(symbol_identifier: "::MyApp::Example1")
    end
  end

  context "when changed file contains the definition of a namespace referenced from another file" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "my_app/example_1.rb", <<~RUBY
        module MyApp
          module Example1
            def self.call; end
          end
        end
        RUBY

        files.add "my_app/example_2.rb", <<~RUBY
        module MyApp
          module Example2
            Example1.call
          end
        end
        RUBY
      end
    end

    let(:file_1_new_source_code) do
      <<~RUBY
      module MyApp
        module Example1Changed
          def self.call; end
        end
      end
      RUBY
    end

    it "re-evaluates type inference for the referencer" do
      expect(application.symbols.find_reference_to("Example1")).to have_attributes(
        conclusion: have_attributes(symbol_identifier: "::MyApp::Example1")
      )

      application.files.find("my_app/example_1.rb").write(file_1_new_source_code)
      described_class.call(application:, file: application.files.find("my_app/example_1.rb"))

      expect(application.symbols.find_reference_to("Example1")).to have_attributes(
        conclusion: nil
      )
    end
  end
end
