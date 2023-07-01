# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Outline do
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
    result = described_class.call(application:, symbol: application.symbols.find("::MyApp::PlusOne"))

    expect(result.dependencies).to be_empty
    expect(result.declarations).to be_empty

    expect(result.references.size).to eql(2)
    expect(result.references).to match_array(
      application.symbols.find_references_to("::MyApp::PlusOne")
    )

    expect(result.dependants).to match_array(
      application.symbols.find("::MyApp::Example1").record
    )
  end
end