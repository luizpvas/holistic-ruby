# frozen_string_literal: true

describe Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet_collection do |files|
      files.add "/my_app/example_1.rb", <<~RUBY
      module MyApp
        module Example1
          def self.call; end
        end
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

  it "parses the code" do
    expect(application.root_scope.serialize).to eql({
      "::" => {
        "MyApp" => {
          "Example1" => {
            "self.call" => {}
          },
          "Example2" => {}
        }
      }
    })

    expect(
      application.scopes.list_scopes_in_file("/my_app/example_1.rb").map(&:fully_qualified_name)
    ).to match_array([
      "::MyApp",
      "::MyApp::Example1",
      "::MyApp::Example1#self.call"
    ])

    expect(
      application.scopes.list_scopes_in_file("/my_app/example_2.rb").map(&:fully_qualified_name)
    ).to match_array([
      "::MyApp",
      "::MyApp::Example2"
    ])

    expect(
      application.references.list_references_in_file("/my_app/example_2.rb").map(&:identifier)
    ).to match_array([
      "/my_app/example_2.rb[2,4,2,12]"
    ])
  end
end
