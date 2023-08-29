# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Repository do
  concerning :Helpers do
    include ::Support::SnippetParser

    def build_cursor(line, column)
      ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line:, column:)
    end
  end

  describe "#find_inner_most_scope_by_cursor" do
    let(:application) do
      parse_snippet <<~RUBY
      a = 1

      module MyApplication
        b = 2

        module MyModule
          def foo
            c = 3
          end
        end
      end
      RUBY
    end

    context "when cursor is not inside a scope" do
      it "returns nil" do
        cursor = build_cursor(0, 0)

        scope = application.scopes.find_inner_most_scope_by_cursor(cursor)

        expect(scope).to be_nil
      end
    end

    context "when cursor is inside a single scope" do
      it "returns the scope" do
        cursor = build_cursor(3, 0)

        scope = application.scopes.find_inner_most_scope_by_cursor(cursor)

        expect(scope.attr(:fully_qualified_name)).to eql("::MyApplication")
      end
    end

    context "when cursor is inside multiple scopes" do
      it "returns the inner most scope" do
        cursor = build_cursor(7, 7)

        scope = application.scopes.find_inner_most_scope_by_cursor(cursor)

        expect(scope.attr(:fully_qualified_name)).to eql("::MyApplication::MyModule#foo")
      end
    end
  end
end