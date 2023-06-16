# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::SnippetParser

  context "when the referenced namespace is declared in the same file" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Example
        end

        class Other
          Example.call
        end
      end
      RUBY
    end

    it "solves the namespace reference" do
      expect(application.symbols.find_reference_to("Example")).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Something),
        conclusion: have_attributes(
          itself: be_a(::Holistic::Ruby::TypeInference::Conclusion),
          dependency_identifier: "::MyApp::Example",
          confidence: :strong
        )
      )
    end

    it "does not register a dependency" do
      expect(application.dependencies.list_dependants(dependency_file_path: "snippet.rb")).to be_empty
    end
  end

  context "when the referenced namespace is declared in another file" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "my_app/example.rb", <<~RUBY
        module MyApp
          class Example; end
        end
        RUBY

        files.add "my_app/other.rb", <<~RUBY
        module MyApp
          module Other
            Example.call
          end
        end
        RUBY
      end
    end

    it "solves the namespace reference" do
      expect(application.symbols.find_reference_to("Example")).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Something),
        conclusion: have_attributes(
          itself: be_a(::Holistic::Ruby::TypeInference::Conclusion),
          dependency_identifier: "::MyApp::Example",
          confidence: :strong
        )
      )
    end

    it "registers a dependency" do
      symbols = application.dependencies.list_dependants(dependency_file_path: "my_app/example.rb")

      expect(symbols.size).to eql(1)
      expect(symbols.first.record).to eql(application.symbols.find_reference_to("Example"))
    end
  end

  context "when the referenced namespace is declared in multiple files" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "my_app/example_1.rb", <<~RUBY
        module MyApp
          def self.call; end

          module Example1; end
        end
        RUBY

        files.add "my_app/example_2.rb", <<~RUBY
        module MyApp
          module Example2; end
        end
        RUBY

        files.add "something.rb", <<~RUBY
        module Something
          MyApp.call
        end
        RUBY
      end
    end

    it "tries its best to guess the source location" do
      symbols = application.dependencies.list_dependants(dependency_file_path: "my_app/example_1.rb")

      expect(symbols.size).to eql(1)
      expect(symbols.first.record).to eql(application.symbols.find_reference_to("MyApp"))
    end
  end

  context "when the clue is a namespace reference and the namespace is found via ancestry scope" do
    # TODO. How?
  end

  context "when the clue is a namespace reference and the namespace does not exist" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Unknown.call
      end
      RUBY
    end

    it "leaves the conclusion empty" do
      expect(application.symbols.find_reference_to("Unknown")).to have_attributes(
        itself: be_a(::Holistic::Ruby::TypeInference::Something),
        conclusion: be_nil
      )
    end
  end

  context "when the dependency is declared on root scope without root scope operator" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "example_1.rb", <<~RUBY
        module Example1
          def self.call; end
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

    it "solves the dependency" do
      expect(application.symbols.find_reference_to("Example1")).to have_attributes(
        conclusion: have_attributes(
          dependency_identifier: "::Example1"
        )
      )
    end
  end

  context "when dependency is a lambda" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        PlusOne = ->(num) { num + 1 }

        PlusOne.call(2)
      end
      RUBY
    end

    it "solves the dependency" do
      expect(application.symbols.find_reference_to("PlusOne")).to have_attributes(
        conclusion: have_attributes(
          dependency_identifier: "::MyApp::PlusOne"
        )
      )
    end
  end
end
