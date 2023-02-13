# frozen_string_literal: true

RSpec.describe Question do
  it "has a version number" do
    expect(Question::VERSION).not_to be nil
  end
end
