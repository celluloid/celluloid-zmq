module Celluloid
  module ZMQ
    class Socket
      # Readable 0MQ sockets have a read method
      module Readable

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

          frame = CZTop::Frame.receive_from(@socket)
          buffer << frame.to_s

          @more_parts = frame.more?
          buffer
        rescue
          raise IOError, "error receiving ZMQ string: #{$!.message}"
        end

        # Multiparts message ?
        def more_parts?
          @more_parts
        end

        # Reads a multipart message, stores it into the given buffer and returns
        # the buffer.
        def read_multipart(buffer = [])
          ZMQ.wait_readable(@socket) if ZMQ.evented?

          CZTop::Message.receive_from(@socket).to_a.each do |part|
            buffer << part
          end

          @more_parts = false # we've read all parts
          buffer
        rescue
          raise IOError, "error receiving ZMQ string: #{$!.message}"
        end
      end
    end
  end
end
