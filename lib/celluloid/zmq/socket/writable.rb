module Celluloid
  module ZMQ
    class Socket
      # Writable 0MQ sockets have a send method
      module Writable
        # Send a message to the socket
        def write(*messages)
          unless ::ZMQ::Util.resultcode_ok? @socket.send_strings messages.flatten
            raise IOError, "error sending 0MQ message: #{::ZMQ::Util.error_string}"
          end

          messages
        end
        alias_method :<<, :write
        alias_method :send, :write # deprecated
      end
    end
  end
end
