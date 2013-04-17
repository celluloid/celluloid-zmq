require 'ffi-rzmq'

require 'celluloid/io'
require 'celluloid/zmq/mailbox'
require 'celluloid/zmq/reactor'
require 'celluloid/zmq/sockets'
require 'celluloid/zmq/version'
require 'celluloid/zmq/waker'

module Celluloid
  # Actors which run alongside 0MQ sockets
  module ZMQ
    class NotZmqActorError < StandardError; end
    class NotZmqSocketError < StandardError; end

    class << self
      attr_writer :context

      # Included hook to pull in Celluloid
      def included(klass)
        klass.send :include, ::Celluloid
        klass.mailbox_class Celluloid::ZMQ::Mailbox
      end

      # Obtain a 0MQ context (or lazily initialize it)
      def context(worker_threads = 1)
        return @context if @context
        @context = ::ZMQ::Context.new(worker_threads)
      end
      alias_method :init, :context

      def terminate
        @context.terminate
      end
    end

    def wait_readable(socket)
      if !socket.is_a?(::ZMQ::Socket)
        throw NotZmqSocketError
      end
      actor = Thread.current[:celluloid_actor]
      if actor && actor.mailbox.is_a?(Celluloid::ZMQ::Mailbox)
        actor.mailbox.reactor.wait_readable(socket)
      else
        throw NotZmqActorError
      end
      nil
    end
    module_function :wait_readable

    def wait_writable(socket)
      actor = Thread.current[:celluloid_actor]
      if actor && actor.mailbox.is_a?(Celluloid::ZMQ::Mailbox)
        actor.mailbox.reactor.wait_writable(socket)
      else
        Kernel.select([], [io])
      end
      nil
    end
    module_function :wait_writable

    # Does the 0MQ socket support evented operation?
    def evented?
      actor = Thread.current[:celluloid_actor]
      return unless actor

      mailbox = actor.mailbox
      mailbox.is_a?(Celluloid::IO::Mailbox) && mailbox.reactor.is_a?(Celluloid::ZMQ::Reactor)
    end
    module_function :evented?

  end
end
