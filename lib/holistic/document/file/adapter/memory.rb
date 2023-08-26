# frozen_string_literal: true

module Holistic::Document::File::Adapter::Memory
  extend self

  def read(file)
    file.in_memory_content
  end

  def write(file, content)
    file.singleton_class.send(:attr_accessor, :in_memory_content)
    
    file.in_memory_content = content
  end
end
