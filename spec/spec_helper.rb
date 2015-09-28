require "rubygems"
require "bundler/setup"

module Specs
  INCLUDED_MODULE = Celluloid::ZMQ
  ALLOW_SLOW_MAILBOXES = true # TODO: Remove hax.
end

require "celluloid/rspec"
require "celluloid/zmq"

Dir[*Specs::INCLUDE_PATHS].map { |f| require f }
