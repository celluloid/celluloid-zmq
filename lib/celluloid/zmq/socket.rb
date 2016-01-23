module Celluloid
  module ZMQ
    class Socket

      # Create a new socket
      def initialize(type)
        type = type.is_a?(Integer) ? type : type.to_s.upcase.to_sym
        @socket = CZTop::Socket.new_by_type(type)
        @linger = 0
      end
      attr_reader :linger

      # Connect to the given 0MQ address
      # Address should be in the form: tcp://1.2.3.4:5678/
      def connect(addr)
        @socket.connect addr
        true
      rescue
        raise IOError, "error connecting to #{addr}: #{$!.message}"
      end

      def linger=(value)
        @linger = value || -1
        @socket.options.linger = value
      rescue
        raise IOError, "couldn't set linger: #{$!.message}"
      end

      def identity=(value)
        @socket.options.identity = "#{value}"
      rescue
        raise IOError, "couldn't set identity: #{$!.message}"
      end

      def identity
        @socket.options.identity
      end

      def set(option, value, length = nil)
        @socket.options[option] = value
      rescue
        raise IOError, "couldn't set value for option #{option}: #{$!.message}"
      end

      def get(option)
        @socket.options[option]
      rescue
        raise IOError, "couldn't get value for option #{option}: #{$!.message}"
      end

      # Bind to the given 0MQ address
      # Address should be in the form: tcp://1.2.3.4:5678/
      def bind(addr)
        @socket.bind(addr)
      rescue
        raise IOError, "couldn't bind to #{addr}: #{$!.message}"
      end

      # Close the socket
      def close
        @socket.close
      end
    end
  end
end

unless defined?(::ZMQ)
  # Make legacy code like this work:
  #
  #   zmq_socket.set(::ZMQ::IDENTITY, "foo")
  #   zmq_socket.get(::ZMQ::IDENTITY)
  #
  # This assumes that the user didn't require 'ffi-rzmq' themselves, but had
  # it done by celluloid-zmq.
  module ZMQ
    def self.const_missing(name)
      Celluloid.logger.deprecate("Using ZMQ::#{name} as an option name is deprecated. Please report if you need this, so it can be added to Celluloid::ZMQ::Socket."
      return name
    end
  end
end
