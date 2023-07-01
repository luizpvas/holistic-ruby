# frozen_string_literal: true

module Holistic::LanguageServer::Format
  module FileUri
    extend self

    def extract_path(file_uri)
      uri = URI(file_uri)

      return uri.path if uri.is_a?(URI::File)

      nil
    end

    def from_path(file_path)
      "file://#{file_path}"
    end
  end
end