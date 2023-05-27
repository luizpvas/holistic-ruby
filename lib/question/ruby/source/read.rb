# frozen_string_literal: true

module Question::Ruby::Source
  Read = ->(location) { ::File.read(location.file_path) }
end
