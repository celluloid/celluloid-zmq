require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'
require 'celluloid/zmq'
require 'celluloid/rspec'

module CelluloidSpecs
  # Require a file from Celluloid gem 'spec' location directly
  def self.require(path)
    celluloid = Pathname(Gem::Specification.find_all_by_name('celluloid').first.full_gem_path)
    full_path = celluloid + 'spec' + path
    Kernel.require(full_path.to_s)
  end

  def self.included_module
    Celluloid::ZMQ
  end

  # Timer accuracy enforced by the tests (50ms)
  TIMER_QUANTUM = 0.05
end

logfile = File.open(File.expand_path("../../log/test.log", __FILE__), 'a')
Celluloid.logger = Logger.new(logfile)

Celluloid.shutdown_timeout = 1

RSpec.configure(&:disable_monkey_patching!)

RSpec.configure do |config|
  config.around do |ex|
    Celluloid.boot
    ex.run
    Celluloid.shutdown
  end

  config.before(:each) do |example|
    @fake_logger = Specs::FakeLogger.new(Celluloid.logger, example.description)
    stub_const('Celluloid::Internals::Logger', @fake_logger)
  end
end
