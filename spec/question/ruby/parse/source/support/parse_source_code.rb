# frozen_string_literal: true

module ParseSourceCode
  def detect_references(source)
    application = ::Question::Ruby::Application.new

    ::Question::Ruby::Parse::Source.call(application:, source:)

    application.repository.references
  end
end
