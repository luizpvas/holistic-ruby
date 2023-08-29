# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Lexical do
  include ::Support::SnippetParser

  describe "#descendant?" do
    let(:application) do
      parse_snippet <<~RUBY
      module Child1; end

      module Child2
        module Child2A; end
      end
      RUBY
    end

    let(:root)      { application.scopes.root }
    let(:child_1)   { application.scopes.find("::Child1") }
    let(:child_2)   { application.scopes.find("::Child2") }
    let(:child_2_a) { application.scopes.find("::Child2::Child2A") }

    it "returns false for itself" do
      expect(described_class.descendant?(child: child_1, parent: child_1)).to be(false)
      expect(described_class.descendant?(child: root, parent: root)).to be(false)
    end

    it "returns true for direct children" do
      expect(described_class.descendant?(child: child_1, parent: root)).to be(true)
      expect(described_class.descendant?(child: child_2, parent: root)).to be(true)
    end

    it "returns true for children of children (recursively)" do
      expect(described_class.descendant?(child: child_2_a, parent: root)).to be(true)
    end

    it "returns false scope is not present in ancestry tree" do
      expect(described_class.descendant?(child: child_1, parent: child_2)).to be(false)
      expect(described_class.descendant?(child: child_2, parent: child_1)).to be(false)
      expect(described_class.descendant?(child: child_2_a, parent: child_1)).to be(false)
      expect(described_class.descendant?(child: root, parent: child_1)).to be(false)
    end
  end
end
