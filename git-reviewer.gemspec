# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitreviewer/version'

require_relative "lib/gitreviewer/version"

Gem::Specification.new do |spec|
  spec.name = "git-reviewer"
  spec.version = GitReviewer::VERSION
  spec.authors = ["baochuquan"]
  spec.email = ["baochuquan@163.com"]

  spec.summary = "A git plugin that can automatically analyze code reviewers."
  spec.description = "Helps you solve the problem of who should review your code."
  spec.homepage = "https://github.com/baochuquan/git-reviewer"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/baochuquan/git-reviewer"
  spec.metadata["changelog_uri"] = "https://github.com/baochuquan/git-reviewer"

  spec.files         = Dir['{exe,lib}/**/*', 'LICENSE.txt', 'README.md', 'CHANGELOG.md']
  spec.bindir = "exe"
  spec.executables = "git-reviewer"
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'claide', '~> 1.1.0'
  spec.add_dependency 'terminal-table', '~> 3.0.2'
  spec.add_dependency 'claide-plugins', '~> 0.9.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
