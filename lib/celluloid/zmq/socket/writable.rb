module Celluloid
  module ZMQ
    class Socket
      # Writable 0MQ sockets have a send method
      module Writable

        # Send a message to the socket
        def write(*messages)
          @socket << messages.flatten
          messages
        rescue
          raise IOError, "error sending 0MQ message: #{$!.message}"
        end
        alias_method :<<, :write

        # @deprecated
        alias_method :send, :write

        def write_to(address, message)
          @socket.send_to(address, message)
          message
        rescue
          raise IOError,
            "error sending message to #{address.inspect}: #{$!.message}"
        end

      end
    end
  end
end
