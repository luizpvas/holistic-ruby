# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when the referenced scope is declared in the same file" do
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

    it "solves the scope reference" do
      reference = application.references.find_reference_to("Example")

      expect(reference).to be_a(::Holistic::Ruby::Reference::Record)
      expect(reference.scope.fully_qualified_name).to eql("::MyApp::Other")
      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyApp::Example")
    end

    it "registers a dependency between the scope and its references" do
      references = application.references.list_references_to_scopes_in_file(scopes: application.scopes, file_path: "/snippet.rb")

      expect(references.size).to eql(1)
      expect(references.first).to eql(application.references.find_reference_to("Example"))
    end
  end

  context "when the referenced scope is declared in another file" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "/my_app/example.rb", <<~RUBY
        module MyApp
          class Example; end
        end
        RUBY

        files.add "/my_app/other.rb", <<~RUBY
        module MyApp
          module Other
            Example.call
          end
        end
        RUBY
      end
    end

    it "solves the scope reference" do
      reference = application.references.find_reference_to("Example")

      expect(reference).to be_a(::Holistic::Ruby::Reference::Record)
      expect(reference.scope.fully_qualified_name).to eql("::MyApp::Other")
      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyApp::Example")
    end

    it "registers a dependency between the scope and its references" do
      references = application.references.list_references_to_scopes_in_file(scopes: application.scopes, file_path: "/my_app/example.rb")

      expect(references.size).to eql(1)
      expect(references.first).to eql(application.references.find_reference_to("Example"))
    end
  end

  context "when the referenced scope is declared in multiple files" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "/my_app/example_1.rb", <<~RUBY
        module MyApp
          def self.call; end

          module Example1; end
        end
        RUBY

        files.add "/my_app/example_2.rb", <<~RUBY
        module MyApp
          module Example2; end
        end
        RUBY

        files.add "/something.rb", <<~RUBY
        module Something
          MyApp.call
        end
        RUBY
      end
    end

    it "tries its best to guess the source location" do
      references = application.references.list_references_to_scopes_in_file(scopes: application.scopes, file_path: "/my_app/example_1.rb")

      expect(references).to match_array([
        application.references.find_by_code_content("MyApp"),
        application.references.find_by_code_content("MyApp.call")
      ])
    end
  end

  context "when the clue is a scope reference and the scope is found via ancestry lookup" do
    # TODO. How?
  end

  context "when referenced scope does not exist" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        Unknown.call
      end
      RUBY
    end

    it "leaves the referenced_by connection empty" do
      reference = application.references.find_reference_to("Unknown")

      expect(reference).to be_a(::Holistic::Ruby::Reference::Record)
      expect(reference.referenced_scope).to be_nil
    end
  end

  context "when the dependency is declared on root scope without root scope operator" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "/example_1.rb", <<~RUBY
        module Example1
          def self.call; end
        end
        RUBY

        files.add "/my_app/example_2.rb", <<~RUBY
        module MyApp
          module Example2
            Example1.call
          end
        end
        RUBY
      end
    end

    it "solves the dependency" do
      reference = application.references.find_reference_to("Example1")

      expect(reference.scope.fully_qualified_name).to eql("::MyApp::Example2")
      expect(reference.referenced_scope.fully_qualified_name).to eql("::Example1")
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
      reference = application.references.find_reference_to("PlusOne")

      expect(reference.scope.fully_qualified_name).to eql("::MyApp")
      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyApp::PlusOne")
    end
  end
end
