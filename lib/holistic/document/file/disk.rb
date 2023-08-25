# frozen_string_literal: true

module Holistic::Document::File::Disk
  extend self

  def read(file)
    ::File.read(file.path)
  end

  def write(file, content)
    ::File.write(file.path, content)
  end
end
