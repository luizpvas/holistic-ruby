# frozen_string_literal: true

module ParseSourceCode
  def detect_references(code)
    application = ::Question::Ruby::Application.new

    ::Question::Ruby::Parser::ParseCode[application:, code:]

    application.repository.references
  end
end
