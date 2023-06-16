# frozen_string_literal: true

module Holistic::Cli::Start
  extend self

  def call(root_directory:)
    name = ::File.basename(root_directory)

    application = ::Holistic::Ruby::Application::Repository.create(name:, root_directory:)

    ::Holistic::Ruby::Parser::WrapParsingUnitWithProcessAtTheEnd[application:] do
      ::Holistic::Ruby::Parser::ParseDirectory[application:, directory_path: root_directory]
    end

    ::Holistic::HttpApplication.run!
  end
end
