# frozen_string_literal: true

describe ::Question::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::SnippetParser

  context "when file content does not change" do
    let(:application) do
      parse_snippet <<~RUBY

      RUBY
    end

    it "ends up in the same state as before the change"
  end

  context "when file content is different" do
    it "deletes symbols from previous content and parses the new one"
  end
end