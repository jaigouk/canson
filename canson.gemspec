# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'canson/version'

Gem::Specification.new do |spec|
  spec.name          = "canson"
  spec.version       = Canson::VERSION
  spec.authors       = ["Jaigouk Kim"]
  spec.email         = ["ping@jaigouk.kim"]

  spec.summary       = %q{grpc}
  spec.description   = %q{grpc based webframework}
  spec.homepage      = "https://github.com/jaigouk/canson"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dry-monads', '~> 0.2.1'
  spec.add_dependency 'dry-matcher', '~> 0.5'
  spec.add_dependency 'dry-transaction', '~> 0.8'
  spec.add_dependency 'grpc', '~> 1.0.1'
  spec.add_dependency 'http-2', '~> 0.8.2'
  spec.add_dependency 'http_parser.rb', '~> 0.6'
  spec.add_dependency 'dotenv'
  # spec.add_runtime_dependency 'grpc', '~> 1.0.1'
  spec.add_runtime_dependency 'grpc-tools', '~> 1.0.1'
  spec.add_runtime_dependency 'iodine', '~> 0.2.3'
  spec.add_runtime_dependency 'rack', '~> 2.0.1'
  spec.add_runtime_dependency 'tilt', '~> 2.0.5'
  spec.add_runtime_dependency 'mustermann', '~> 0.4'
  spec.add_runtime_dependency 'mime-types', '~> 2.4'
end
