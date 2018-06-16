
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kriterion/version"

Gem::Specification.new do |spec|
  spec.name          = "kriterion"
  spec.version       = Kriterion::VERSION
  spec.authors       = ["Dylan Ratcliffe"]
  spec.email         = ["dylan.ratcliffe@puppet.com"]

  spec.summary       = %q{Exposes Puppet's compliance information in a REST API}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/dylanratcliffe/kriterion"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cri", "~> 2.10"
  spec.add_runtime_dependency "mongo", "~> 2.5"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
