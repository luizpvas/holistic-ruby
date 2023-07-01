# frozen_string_literal: true

describe ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::SnippetParser

  context "when file content did not change" do
    let(:source_code) do
      <<~RUBY
      module MyApp
        module Example
          Foo.call
        end
      end
      RUBY
    end

    let(:application) { parse_snippet(source_code) }

    it "ends up in the same state as before the change" do
      my_app_before = application.symbols.find("::MyApp")
      my_app_example_before = application.symbols.find("::MyApp::Example")
      foo_reference_before = application.symbols.find_reference_to("Foo")

      file = ::Holistic::Document::File::Fake.new(path: "/snippet.rb", content: source_code)
      described_class.call(application:, file:)

      my_app_after = application.symbols.find("::MyApp")
      my_app_example_after = application.symbols.find("::MyApp::Example")
      foo_reference_after = application.symbols.find_reference_to("Foo")

      expect(my_app_before.identifier).to eql(my_app_after.identifier)
      expect(my_app_before).not_to be(my_app_after)

      expect(my_app_example_before.identifier).to eql(my_app_example_after.identifier)
      expect(my_app_example_before).not_to be(my_app_example_after)

      expect(foo_reference_before.identifier).to eql(foo_reference_after.identifier)
      expect(foo_reference_before).not_to be(foo_reference_after)
    end
  end

  context "when file content is different" do
    let(:source_code_before) do
      <<~RUBY
      module MyApp
        module Example1
          Foo1.call
        end
      end
      RUBY
    end

    let(:source_code_after) do
      <<~RUBY
      module MyApp
        module Example2
          Foo2.call
        end
      end
      RUBY
    end

    let(:application) { parse_snippet(source_code_before) }

    it "deletes symbols from previous content and parses new ones" do
      my_app_before = application.symbols.find("::MyApp")
      my_app_example_1_before = application.symbols.find("::MyApp::Example1")
      my_app_example_2_before = application.symbols.find("::MyApp::Example2")
      foo_1_reference_before = application.symbols.find_reference_to("Foo1")
      foo_2_reference_before = application.symbols.find_reference_to("Foo2") rescue nil

      file = ::Holistic::Document::File::Fake.new(path: "/snippet.rb", content: source_code_after)
      described_class.call(application:, file:)

      my_app_after = application.symbols.find("::MyApp")
      my_app_example_1_after = application.symbols.find("::MyApp::Example1")
      my_app_example_2_after = application.symbols.find("::MyApp::Example2")
      foo_1_reference_after = application.symbols.find_reference_to("Foo1") rescue nil
      foo_2_reference_after = application.symbols.find_reference_to("Foo2")

      expect(my_app_before.identifier).to eql(my_app_after.identifier)
      expect(my_app_before).not_to be(my_app_after)

      expect(my_app_example_1_before).to be_a(::Holistic::Ruby::Symbol::Record)
      expect(my_app_example_1_after).to be_nil

      expect(my_app_example_2_before).to be_nil
      expect(my_app_example_2_after).to be_a(::Holistic::Ruby::Symbol::Record)

      expect(foo_1_reference_before).to be_a(::Holistic::Ruby::TypeInference::Reference)
      expect(foo_2_reference_before).to be_nil

      expect(foo_1_reference_after).to be_nil
      expect(foo_2_reference_after).to be_a(::Holistic::Ruby::TypeInference::Reference)
    end
  end
end