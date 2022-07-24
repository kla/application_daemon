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

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  unless spec.respond_to?(:metadata)
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.add_development_dependency "minitest"
end
