# frozen_string_literal: true

module Question::SourceCode
  class FromFile
    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def unformatted_and_unhighlighted
      ::File.read(file_path)
    end
  end
end
