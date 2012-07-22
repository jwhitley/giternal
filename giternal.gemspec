$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "giternal/version"

Gem::Specification.new do |s|
  s.name = "giternal"
  s.version = Giternal::Version
  s.authors = ["John Whitley", "Pat Maddox"]
  s.email = ["john@luminous-studios.com"]
  s.homepage = "http://github.com/jwhitley/giternal"
  s.summary = "Non-sucky git externals"
  s.description = "Giternal provides dead-simple management of external git dependencies. It only stores a small bit of metadata, letting you actively develop in any of the repos. Come deploy time, you can easily freeze freeze all the dependencies to particular versions"

  s.executables = ["giternal"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  git_test_files, git_files = `git ls-files`.split("\n").partition { |f| f =~ %r{(^test|^spec)/} }
  s.test_files = git_test_files
  s.files = git_files

  s.post_install_message = "** IMPORTANT - Please see UPGRADING.rdoc for important changes **"
  s.require_paths = ["lib"]

  s.add_dependency("ruby-git", ["~> 0.2"])
  s.add_development_dependency("rake", ["~> 0.9"])
  s.add_development_dependency("rspec", ["~> 2"])
  s.add_development_dependency("cucumber", ["~> 1"])
end

