# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  # extracted from newrelic-ruby-agent
  let(:application) do
    parse_snippet <<~RUBY
    class MyClass < (defined?(::ActiveSupport) && defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger : ::Logger)
    end
    RUBY
  end

  it "parses the code" do
    expect(application.scopes.find_by_fully_qualified_name("::MyClass")).to have_attributes(
      name: "MyClass"
    )
  end
end
