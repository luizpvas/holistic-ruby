# frozen_string_literal: true

describe ::Question::Ruby::Parser do
  describe ".call" do
    context "module declaration in the root namespace" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        module MyModule
          Foo.bar()
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Foo")
        expect(references.first.namespace).to have_attributes(
          itself: be_a(::Question::Ruby::Constant::Namespace),
          name: "MyModule"
        )
      end
    end

    context "module declaration in root scope with double colon syntax" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        module MyApp::MyModule
          Foo.bar()
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores a reference in the module namespace" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Foo")
        expect(references.first.namespace).to have_attributes(
          itself: be_a(::Question::Ruby::Constant::Namespace),
          name: "MyApp::MyModule",
        )
      end
    end

    context "module declaration with nested syntax" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        module MyApp
          module MyModule
            Foo.bar()
          end
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Foo")
        expect(references.first.namespace).to have_attributes(
          itself: be_a(::Question::Ruby::Constant::Namespace),
          name: "MyModule",
          parent: have_attributes(
            itself: be_a(::Question::Ruby::Constant::Namespace),
            name: "MyApp"
          )
        )
      end
    end

    context "module declaration with nested syntax AND double colon syntax" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        module MyApp
          module MyModule1::MyModule2
            Name.foo()
          end
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Name")
        expect(references.first.namespace.name).to eql("MyModule1::MyModule2")
        expect(references.first.namespace.parent.name).to eql("MyApp")
      end
    end

    context "duplicated module declaration" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        module MyApp
          module MyModule
            Foo1.bar()
          end

          module MyModule
            Foo2.bar()
          end
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores two source locations for the module" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(2)

        expect(references[0].name).to eql("Foo1")
        expect(references[1].name).to eql("Foo2")

        expect(references[0].namespace).to be(references[1].namespace)
      end
    end

    context "class declaration in root namespace" do
      subject(:parse_code) { described_class::ParseCode[application:, code:] }

      let(:application) { ::Question::Ruby::Application.new }

      let(:code) do
        <<-RUBY
        class MyClass
          Foo.bar()
        end
        RUBY
      end

      it "finishes the parsing process in root namespace" do
        parse_code

        expect(application.repository.namespace.root?).to be(true)
      end

      it "stores a constant reference in the class namespace" do
        parse_code

        references = application.repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Foo")
        expect(references.first.namespace.name).to eql("MyClass")
      end
    end
  end
end
