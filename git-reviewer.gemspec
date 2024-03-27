# frozen_string_literal: true

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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = "git-reviewer"
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'claide', '~> 1.0.3'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
