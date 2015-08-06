module Celluloid
  module ZMQ
    class Socket
      # Writable 0MQ sockets have a send method
      module Writable
        extend Forwardable
        def_delegator ZMQ, :result_ok?
        # Send a message to the socket
        def write(*messages)
          unless result_ok? @socket.send_strings(messages.flatten)
            raise IOError, "error sending 0MQ message: #{::ZMQ::Util.error_string}"
          end

          messages
        end
        alias_method :<<, :write
        alias_method :send, :write # deprecated

        def write_to(address, message)
          error = [IOError, "Failure sending part of message."]
          raise *error unless result_ok? @socket.send_string("#{address}", ::ZMQ::SNDMORE)
          raise *error unless result_ok? @socket.send_string("", ::ZMQ::SNDMORE)
          raise *error unless result_ok? @socket.send_string(message)
          message
        end

      end
    end
  end
end
