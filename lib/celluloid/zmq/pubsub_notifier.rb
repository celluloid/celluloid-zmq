module Celluloid
  module ZMQ
    class PubsubNotifier < Celluloid::Notifications::Fanout
      include Celluloid::ZMQ

      attr_accessor :peers, :endpoint

      finalizer :close

      def initialize(endpoint, peer_endpoints=[])
        super()

        @endpoint = endpoint
        init_pub_socket if @endpoint
        init_sub_socket

        Array(peer_endpoints).each do |peer_endpoint|
          add_peer(peer_endpoint)
        end

        async.listen
      end

      def init_pub_socket
        @pub.close if @pub

        @pub = PubSocket.new

        begin
          @pub.bind(@endpoint)
        rescue IOError => e
          @pub.close
          raise e
        end
      end

      def init_sub_socket
        @sub.close if @sub

        @sub = SubSocket.new
        @sub.subscribe("")

        #TODO add peers? could end up looping
      end

      def add_peer(endpoint)
        @peers ||= []
        begin
          @peers << endpoint
          @sub.connect(endpoint)
        rescue IOError => e
          @sub.close
          raise e
        end
      end

      def listen
        loop do
          pattern = @sub.read
          args = []
          while @sub.more_parts?
            args << @sub.read
          end
          listeners_for(pattern).each { |s| s.publish(pattern, *args) }
        end
      end

      def publish(pattern, *args)
        @pub.write(pattern, *args) if @pub
      end

      def close
        @pub.close if @pub
        @sub.close if @sub
      end
    end
  end
end
