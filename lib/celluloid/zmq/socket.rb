module Celluloid
  module ZMQ
    class Socket
      # Create a new socket
      def initialize(type)
        @socket = Celluloid::ZMQ.context.socket ::ZMQ.const_get(type.to_s.upcase)
        @linger = 0
      end
      attr_reader :linger

      # Connect to the given 0MQ address
      # Address should be in the form: tcp://1.2.3.4:5678/
      def connect(addr)
        unless ::ZMQ::Util.resultcode_ok? @socket.connect addr
          raise IOError, "error connecting to #{addr}: #{::ZMQ::Util.error_string}"
        end
        true
      end

      def linger=(value)
        @linger = value || -1

        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(::ZMQ::LINGER, value)
          raise IOError, "couldn't set linger: #{::ZMQ::Util.error_string}"
        end
      end

      def identity=(value)
        @socket.identity = value
      end

      def identity
        @socket.identity
      end

      def set(option, value, length = nil)
        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(option, value, length)
          raise IOError, "couldn't set value for option #{option}: #{::ZMQ::Util.error_string}"
        end
      end

      def get(option)
        option_value = []

        unless ::ZMQ::Util.resultcode_ok? @socket.getsockopt(option, option_value)
          raise IOError, "couldn't get value for option #{option}: #{::ZMQ::Util.error_string}"
        end

        option_value[0]
      end

      # Bind to the given 0MQ address
      # Address should be in the form: tcp://1.2.3.4:5678/
      def bind(addr)
        unless ::ZMQ::Util.resultcode_ok? @socket.bind(addr)
          raise IOError, "couldn't bind to #{addr}: #{::ZMQ::Util.error_string}"
        end
      end

      # Close the socket
      def close
        @socket.close
      end

      # Hide ffi-rzmq internals
      alias_method :inspect, :to_s
    end
  end
end
