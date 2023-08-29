# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Outline do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      PlusOne = ->(x) { x + 1 }

      module Example1
        PlusOne.call(2)
        PlusOne.call(3)
      end
    end
    RUBY
  end

  it "outlines a lambda with no dependencies and two references" do
    result = described_class.call(application:, scope: application.scopes.find("::MyApp::PlusOne"))

    expect(result.dependencies).to be_empty
    
    expect(
      result.declarations.map { _1.attr(:fully_qualified_name) }
    ).to match_array(["::MyApp::PlusOne.call", "::MyApp::PlusOne.curry"])

    expect(result.references.size).to be(2)

    expect(result.dependants).to match_array([
      application.scopes.find("::MyApp::Example1")
    ])
  end
end
