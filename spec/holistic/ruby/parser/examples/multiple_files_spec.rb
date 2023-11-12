# frozen_string_literal: true

describe Holistic::Ruby::Parser do
  include ::Support::SnippetParser
  include ::Support::Ruby::Serializer

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
    expect(serialize_scope(application.scopes.root)).to eql({
      "::" => {
        "MyApp" => {
          "Example1" => {
            "call" => {}
          },
          "Example2" => {}
        }
      }
    })

    expect(
      application.scopes.list_scopes_in_file("/my_app/example_1.rb").map { _1.fully_qualified_name }
    ).to match_array([
      "::MyApp",
      "::MyApp::Example1",
      "::MyApp::Example1.call"
    ])

    expect(
      application.scopes.list_scopes_in_file("/my_app/example_2.rb").map { _1.fully_qualified_name }
    ).to match_array([
      "::MyApp",
      "::MyApp::Example2"
    ])

    expect(
      application.references.list_references_in_file("/my_app/example_2.rb").map { _1.identifier }
    ).to match_array([
      "/my_app/example_2.rb[2,4,2,12]",
      "/my_app/example_2.rb[2,13,2,17]"
    ])
  end
end
