module Celluloid
  module ZMQ
    class Socket
      # Readable 0MQ sockets have a read method
      module Readable
        extend Forwardable
        def_delegator ZMQ, :result_ok?

        # always set LINGER on readable sockets
        def bind(addr)
          self.linger = @linger
          super(addr)
        end

        def connect(addr)
          self.linger = @linger
          super(addr)
        end

        # Read a message from the socket
        def read(buffer = '')
          ZMQ.wait_readable(@socket) if ZMQ.evented?

          unless result_ok? @socket.recv_string buffer
            raise IOError, "error receiving ZMQ string: #{::ZMQ::Util.error_string}"
          end
          buffer
        end

        # Multiparts message ?
        def_delegator :@socket, :more_parts?

        # Reads a multipart message, stores it into the given buffer and returns
        # the buffer.
        def read_multipart(buffer = [])
          ZMQ.wait_readable(@socket) if ZMQ.evented?

          unless result_ok? @socket.recv_strings buffer
            raise IOError, "error receiving ZMQ string: #{::ZMQ::Util.error_string}"
          end
          buffer
        end
      end
    end
  end
end
