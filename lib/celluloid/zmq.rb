require 'ffi-rzmq'

$CELLULOID_ZMQ_BACKPORTED = (ENV["CELLULOID_ZMQ_BACKPORTED"] != "false") unless defined?($CELLULOID_ZMQ_BACKPORTED)

require ($CELLULOID_ZMQ_BACKPORTED) ? 'celluloid' : 'celluloid/current'

require 'celluloid/zmq/mailbox'
require 'celluloid/zmq/reactor'
require 'celluloid/zmq/socket'
require 'celluloid/zmq/version'
require 'celluloid/zmq/waker'

require 'celluloid/zmq/socket/readable'
require 'celluloid/zmq/socket/writable'
require 'celluloid/zmq/socket/types'

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

      # Obtain a 0MQ context
      def init(worker_threads = 1)
        @context ||= ::ZMQ::Context.new(worker_threads)
      end

      def context
        raise UninitializedError, "you must initialize Celluloid::ZMQ by calling Celluloid::ZMQ.init" unless @context
        @context
      end

      def terminate
        @context.terminate if @context
        @context = nil
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
        raise ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end
    module_function :wait_readable

    def wait_writable(socket)
      if ZMQ.evented?
        mailbox = Thread.current[:celluloid_mailbox]
        mailbox.reactor.wait_writable(socket)
      else
        raise ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end
    module_function :wait_writable

    def result_ok?(result)
      ::ZMQ::Util.resultcode_ok?(result)
    end
    module_function :result_ok?

  end
end

require 'celluloid/zmq/deprecate' unless $CELLULOID_BACKPORTED == false || $CELLULOID_ZMQ_BACKPORTED == false
