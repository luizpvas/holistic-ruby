# frozen_string_literal: true

describe Question::Ruby::Parser do
  include ::SnippetParser

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

  it "parses the code" do
    expect(application.root_namespace.serialize).to eql({
      "::" => {
        "MyApp" => {
          "Example1" => {},
          "Example2" => {}
        }
      }
    })

    expect(application.symbols.from_file_path_to_identifier).to eql({
      "my_app/example_1.rb" => ::Set.new(["::MyApp", "::MyApp::Example1"]),
      "my_app/example_2.rb" => ::Set.new(["::MyApp", "::MyApp::Example2", "my_app/example_2.rb[3,4,3,12]"]),
    })
  end
end
