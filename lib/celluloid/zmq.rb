require 'cztop'

$CELLULOID_ZMQ_BACKPORTED = (ENV["CELLULOID_ZMQ_BACKPORTED"] != "false") unless defined?($CELLULOID_ZMQ_BACKPORTED)

require ($CELLULOID_ZMQ_BACKPORTED) ? "celluloid" : "celluloid/current"

require "celluloid/zmq/mailbox"
require "celluloid/zmq/reactor"
require "celluloid/zmq/socket"
require "celluloid/zmq/version"
require "celluloid/zmq/waker"

require "celluloid/zmq/socket/readable"
require "celluloid/zmq/socket/writable"
require "celluloid/zmq/socket/types"

module Celluloid
  # Actors which run alongside 0MQ sockets
  module ZMQ
    class UninitializedError < Celluloid::Error; end

    class << self
      attr_writer :context

      # Included hook to pull in Celluloid
      def included(klass)
        klass.send :include, ::Celluloid
        klass.mailbox_class Celluloid::ZMQ::Mailbox
      end

      # @deprecated
      def init(worker_threads = 1)
        Celluloid::Internals::Logger.deprecate("Calling .init isn't needed anymore")
      end

      # @deprecated
      def context
        Celluloid::Internals::Logger.deprecate("Accessing ZMQ's context is deprecated")
      end

      # @deprecated
      def terminate
        Celluloid::Internals::Logger.deprecate("Calling .terminate isn't needed anymore")
      end
    end

    # Is this a Celluloid::ZMQ evented actor?
    def self.evented?
      actor = Thread.current[:celluloid_actor]
      actor.mailbox.is_a?(Celluloid::ZMQ::Mailbox)
    end

    def wait_readable(socket)
      if ZMQ.evented?
        mailbox = Thread.current[:celluloid_mailbox]
        mailbox.reactor.wait_readable(socket)
      else
        fail ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end
    module_function :wait_readable

    def wait_writable(socket)
      if ZMQ.evented?
        mailbox = Thread.current[:celluloid_mailbox]
        mailbox.reactor.wait_writable(socket)
      else
        fail ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end
    module_function :wait_writable

    # @deprecated
    def result_ok?(result)
      Celluloid::Internals::Logger.deprecate("Checking results of ZMQ operations isn't needed anymore")
      true
    end
    module_function :result_ok?
  end
end

require "celluloid/zmq/deprecate" unless $CELLULOID_BACKPORTED == false || $CELLULOID_ZMQ_BACKPORTED == false
