require_relative "application_daemon/base"

module ApplicationDaemon
  autoload :Queue, "#{File.dirname(__FILE__)}/application_daemon/queue"
  autoload :VERSION, "#{File.dirname(__FILE__)}/application_daemon/version"
end
