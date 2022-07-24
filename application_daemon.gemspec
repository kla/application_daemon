require_relative "lib/application_daemon/version"

Gem::Specification.new do |spec|
  spec.name           = "application_daemon"
  spec.version        = ::ApplicationDaemon::VERSION
  spec.authors        = [ "Kien La" ]
  spec.email          = [ "la.kien@gmail.com" ]
  spec.description    = "ApplicationDaemon"
  spec.summary        = spec.description
  spec.homepage       = "https://github.com/kla/application_daemon"
  spec.license        = "MIT"
  spec.files          = ::Dir.glob("{lib}/**/*")
  spec.require_paths  = [ "lib" ]

  spec.required_ruby_version = ">= 3.0"

  spec.metadata["allowed_push_host"] = "https://github.com/kla/application_daemon"

  spec.add_development_dependency "minitest"
end
