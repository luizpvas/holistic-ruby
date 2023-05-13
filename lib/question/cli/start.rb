# frozen_string_literal: true

module Question::Cli::Start
  extend self

  def call(root_directory:)
    name = ::File.basename(path)

    ::Question::Ruby::Application::Repository.create(name:, root_directory:)

    ::Question::HttpApplication.run!
  end
end
