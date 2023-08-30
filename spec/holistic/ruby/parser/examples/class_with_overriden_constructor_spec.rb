# frozen_string_literal: true

describe ::Holistic::Ruby::Parser do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module Holistic::LanguageServer
      class Lifecycle
        UnexpectedStateError = ::Class.new(::StandardError)

        attr_reader :state

        def initialize
          @state = :waiting_initialize_event
        end

        def waiting_initialized_event!
          if @state != :waiting_initialize_event
            raise UnexpectedStateError, "state must be :waiting_initialize_event, got: #{@state.inspect}"
          end

          @state = :waiting_initialized_event
        end

        def shutdown!
          if @state != :initialized
            raise UnexpectedStateError, "state must be :initialized, got: #{@state.inspect}"
          end

          @state = :shutdown
        end
      end
    end
    RUBY
  end

  it "finds the class methods from the cursor position" do
    cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 7, column: 0)
    scope = application.scopes.find_inner_most_scope_by_cursor(cursor)
    expect(scope.fully_qualified_name).to eql("::Holistic::LanguageServer::Lifecycle#initialize")

    cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 11, column: 0)
    scope = application.scopes.find_inner_most_scope_by_cursor(cursor)
    expect(scope.fully_qualified_name).to eql("::Holistic::LanguageServer::Lifecycle#waiting_initialized_event!")
  end
end
