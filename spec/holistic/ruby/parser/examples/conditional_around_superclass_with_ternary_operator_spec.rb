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

  it "parses the code correctly" do
    expect(
      application.scopes.find("::MyClass").name
    ).to eql("MyClass")
  end
end
