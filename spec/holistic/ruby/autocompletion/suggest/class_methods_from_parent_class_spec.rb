# frozen_string_literal: true

describe ::Holistic::Ruby::Autocompletion::Suggester do
  concerning :Helpers do
    include ::Support::SnippetParser

    def assert_suggestions(code, suggestions)
      scope = application.scopes.find("::MyApp::Child.child_method")

      piece_of_code = ::Holistic::Ruby::Autocompletion::PieceOfCode.new(code)

      actual_suggestions = piece_of_code.suggester.suggest(scope:).map do |suggestion|
        { code: suggestion.code, kind: suggestion.kind }
      end

      expect(actual_suggestions).to eql(suggestions)
    end
  end

  context "when suggesting class methods from parent class" do
    let(:application) do
      parse_snippet <<~RUBY
      module MyApp
        class Parent
          def self.parent_method
          end
        end

        class Child < Parent
          def self.child_method
            # autocomplete here
          end
        end
      end
      RUBY
    end

    it "suggests methods of the parent class from the child class scope" do
      assert_suggestions("p", [
        { code: "parent_method", kind: :class_method }
      ])
    end

    it "suggests methods from parent from the fully qualified child scope name" do
      assert_suggestions("::MyApp::Child.", [
        { code: "child_method", kind: :class_method },
        { code: "new", kind: :class_method },
        { code: "parent_method", kind: :class_method }
      ])
    end
  end
end
