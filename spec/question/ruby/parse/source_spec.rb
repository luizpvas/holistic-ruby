# frozen_string_literal: true

describe ::Question::Ruby::Parse::Source do
  describe ".call" do
    context "module declaration in the global namespace" do
      subject(:parse_source) { described_class.call(application:, source:) }

      let(:application) { ::Question::Ruby::Application.new }

      let(:source) do
        <<-RUBY
        module MyModule
          Name.foo()
        end
        RUBY
      end

      it "finishes the parsing process in global namespace" do
        parse_source

        expect(application.constant_repository.namespace.global?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_source

        references = application.constant_repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Name")
        expect(references.first.namespace.name).to eql("MyModule")
      end
    end

    context "module declaration in global scope with double colon syntax" do
      subject(:parse_source) { described_class.call(application:, source:) }

      let(:application) { ::Question::Ruby::Application.new }

      let(:source) do
        <<-RUBY
        module MyApp::MyModule
          Name.foo()
        end
        RUBY
      end

      it "finishes the parsing process in global namespace" do
        parse_source

        expect(application.constant_repository.namespace.global?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_source

        references = application.constant_repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Name")
        expect(references.first.namespace.name).to eql("MyApp::MyModule")
      end
    end

    context "module declaration with nested syntax" do
      subject(:parse_source) { described_class.call(application:, source:) }

      let(:application) { ::Question::Ruby::Application.new }

      let(:source) do
        <<-RUBY
        module MyApp
          module MyModule
            Name.foo()
          end
        end
        RUBY
      end

      it "finishes the parsing process in global namespace" do
        parse_source

        expect(application.constant_repository.namespace.global?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_source

        references = application.constant_repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Name")
        expect(references.first.namespace.name).to eql("MyModule")
        expect(references.first.namespace.parent.name).to eql("MyApp")
      end
    end

    context "module declaration with nested syntax AND double colon syntax" do
      subject(:parse_source) { described_class.call(application:, source:) }

      let(:application) { ::Question::Ruby::Application.new }

      let(:source) do
        <<-RUBY
        module MyApp
          module MyModule1::MyModule2
            Name.foo()
          end
        end
        RUBY
      end

      it "finishes the parsing process in global namespace" do
        parse_source

        expect(application.constant_repository.namespace.global?).to be(true)
      end

      it "stores a constant reference for `Name`" do
        parse_source

        references = application.constant_repository.references

        expect(references.size).to eql(1)
        expect(references.first.name).to eql("Name")
        expect(references.first.namespace.name).to eql("MyModule1::MyModule2")
        expect(references.first.namespace.parent.name).to eql("MyApp")
      end
    end
  end
end
