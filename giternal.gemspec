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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.post_install_message = "** IMPORTANT - Please see UPGRADING.rdoc for important changes **"
  s.require_paths = ["lib"]

  s.add_dependency("git", ["~> 1.2"])
  s.add_dependency("log4r", ["~> 1.1"])
  s.add_development_dependency("pry")
  s.add_development_dependency("rake", ["~> 0.9"])
  s.add_development_dependency("rspec", ["~> 2"])
  s.add_development_dependency("cucumber", ["~> 1"])
end

