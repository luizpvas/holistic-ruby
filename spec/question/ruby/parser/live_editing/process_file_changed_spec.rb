# frozen_string_literal: true

describe ::Question::Ruby::Parser::LiveEditing::ProcessFileChanged do
  context "when file content is the same" do
    it "ends up in the same state as before"
  end

  context "when file content is different" do
    it "deletes symbols from previous content and parses the new one"
  end
end
