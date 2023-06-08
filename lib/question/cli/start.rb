# frozen_string_literal: true

module Question::Cli::Start
  extend self

  def call(root_directory:)
    name = ::File.basename(root_directory)

    application = ::Question::Ruby::Application::Repository.create(name:, root_directory:)

    ::Question::Ruby::Parser::WrapParsingUnitWithProcessAtTheEnd[application:] do
      ::Question::Ruby::Parser::ParseDirectory[application:, directory_path: root_directory]
    end

    ::Question::HttpApplication.run!
  end
end
