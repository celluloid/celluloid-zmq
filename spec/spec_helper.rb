require "rubygems"
require "bundler/setup"

module Specs
  INCLUDED_MODULE = Celluloid::ZMQ
end

require "celluloid/rspec"
require "celluloid/zmq"

Dir[*Specs::INCLUDE_PATHS].map { |f| require f }
