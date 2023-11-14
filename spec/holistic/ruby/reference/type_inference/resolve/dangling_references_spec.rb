# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::Ruby::Reference::TypeInference do
  include ::Support::SnippetParser

  context "when reference to namespace fails to resolve" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "/my_app/foo.rb", <<~RUBY
          module MyApp
            class Foo; end
          end
        RUBY
        
        files.add "/my_app/bar.rb", <<~RUBY
          module MyApp
            Foo2.new
          end
        RUBY
      end
    end

    it "resolves dangling references whenever a file changes" do
      reference = application.references.find_by_code_content("Foo2.new")
      expect(reference.referenced_scope).to be_nil

      ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
        application:,
        file_path: "/my_app/foo.rb",
        content: <<~RUBY
          module MyApp
            class Foo2; end
          end
        RUBY
      )

      reference = application.references.find_by_code_content("Foo2.new")
      expect(reference.referenced_scope.fully_qualified_name).to eql("::MyApp::Foo2.new")
    end
  end
end
