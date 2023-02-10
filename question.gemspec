# frozen_string_literal: true

require_relative "lib/question/version"

Gem::Specification.new do |spec|
  spec.name = "question"
  spec.version = Question::VERSION
  spec.authors = ["Luiz Vasconcellos"]
  spec.email = ["luizpvasc@gmail.com"]

  spec.summary = "Static analysis for Ruby"
  spec.description = "Static analysis for Ruby"
  spec.homepage = "https://github.com/luizpvas/question"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "syntax_tree", "~> 6.0"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
