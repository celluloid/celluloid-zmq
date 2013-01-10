module Celluloid
  module ZMQ
    # This class monitors a socket using the ZeroMQ 3.2+ zmq_monitor_socket interface.
    class SocketMonitor
      include Celluloid::ZMQ

      attr_reader :socket, :topic, :flags
      attr_reader :listener

      def initialize(socket, topic, flags=nil)
        @socket = socket
        @topic = topic
        @flags = flags || ::ZMQ::EVENT_ALL

        add_monitor
        connect_listener
        async.listen
      end

      def add_monitor
        @socket.monitor(topic_endpoint, flags)
      end

      def connect_listener
        @listener = Celluloid::ZMQ::PairSocket.new
        @listener.linger = 1
        @listener.connect(topic_endpoint)
      end

      def listen
        loop do
          message = @listener.read_message
          event = ::ZMQ::LibZMQ::EventData.new(message.data)
          dispatch(event)
        end
      end

      # override to handle events.
      def dispatch(event)
        if Celluloid.logger
          Celluloid.logger.debug "got #{event_to_symbol(event.event)} socket event: #{event}"
        end
      end

      def event_to_symbol(event)
        case event
        when ::ZMQ::EVENT_CONNECTED
          :connected
        when ::ZMQ::EVENT_CONNECT_DELAYED
          :connect_delayed
        when ::ZMQ::EVENT_CONNECT_RETRIED
          :connect_retried
        when ::ZMQ::EVENT_LISTENING
          :listening
        when ::ZMQ::EVENT_BIND_FAILED
          :bind_failed
        when ::ZMQ::EVENT_ACCEPTED
          :accepted
        when ::ZMQ::ACCEPT_FAILED
          :accept_failed
        when ::ZMQ::EVENT_CLOSED
          :closed
        when ::ZMQ::EVENT_CLOSE_FAILED
          :close_failed
        when ::ZMQ::EVENT_DISCONNECTED
          :disconnected
        end
      end

      def topic_endpoint
        "inproc://#{topic}"
      end

      def finalizer
        @listener.close if @listener
      end
    end
  end
end
