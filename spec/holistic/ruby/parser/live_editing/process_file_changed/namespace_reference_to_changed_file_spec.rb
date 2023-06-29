# frozen_string_literal: true

describe ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::SnippetParser

  context "when the changed file contents remains the same" do
    let(:example_1_source_code) do
      <<~RUBY
      module MyApp
        module Example1
          def self.call; end
        end
      end
      RUBY
    end

    let(:example_2_source_code) do
      <<~RUBY
      module MyApp
        module Example2
          Example1.call
        end
      end
      RUBY
    end

    let(:application) do
      parse_snippet_collection do |files|
        files.add("my_app/example_1.rb", example_1_source_code)
        files.add("my_app/example_2.rb", example_2_source_code)
      end
    end

    it "ends up in the same state" do
      references_before = application.dependencies.list_references(dependency_file_path: "my_app/example_1.rb")

      expect(references_before.size).to eql(1)
      expect(references_before.first.record.conclusion).to have_attributes(dependency_identifier: "::MyApp::Example1")

      file = ::Holistic::Document::File::Fake.new(path: "my_app/example_1.rb", content: example_1_source_code)
      described_class.call(application:, file:)

      references_after = application.dependencies.list_references(dependency_file_path: "my_app/example_1.rb")

      expect(references_after.size).to eql(1)
      expect(references_after.first.record.conclusion).to have_attributes(dependency_identifier: "::MyApp::Example1")
    end
  end

  context "when changed file contains the definition of a namespace referenced from another file" do
    let(:example_1_source_code_before) do
      <<~RUBY
      module MyApp
        module Example1
          def self.call; end
        end
      end
      RUBY
    end

    let(:example_2_source_code) do
      <<~RUBY
      module MyApp
        module Example2
          Example1.call
        end
      end
      RUBY
    end

    let(:example_1_source_code_after) do
      <<~RUBY
      module MyApp
        module Example1Changed
          def self.call; end
        end
      end
      RUBY
    end

    let(:application) do
      parse_snippet_collection do |files|
        files.add("my_app/example_1.rb", example_1_source_code_before)
        files.add("my_app/example_2.rb", example_2_source_code)
      end
    end

    it "re-evaluates type inference for the referencer" do
      expect(application.symbols.find_reference_to("Example1")).to have_attributes(
        conclusion: have_attributes(dependency_identifier: "::MyApp::Example1")
      )

      file = ::Holistic::Document::File::Fake.new(path: "my_app/example_1.rb", content: example_1_source_code_after)
      described_class.call(application:, file:)

      expect(application.symbols.find_reference_to("Example1")).to have_attributes(
        conclusion: nil
      )
    end
  end
end
