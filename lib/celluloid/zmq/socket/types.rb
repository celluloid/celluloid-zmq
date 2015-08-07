module Celluloid
  module ZMQ
    class Socket
      # ReqSockets are the counterpart of RepSockets (REQ/REP)
      class Req < Socket
        include Readable
        include Writable

        def initialize
          super :req
        end
      end

      # RepSockets are the counterpart of ReqSockets (REQ/REP)
      class Rep < Socket
        include Readable
        include Writable

        def initialize
          super :rep
        end
      end

      # DealerSockets are like ReqSockets but more flexible
      class Dealer < Socket
        include Readable
        include Writable

        def initialize
          super :dealer
        end
      end

      # RouterSockets are like RepSockets but more flexible
      class Router < Socket
        include Readable
        include Writable

        def initialize
          super :router
        end
      end

      # PushSockets are the counterpart of PullSockets (PUSH/PULL)
      class Push < Socket
        include Writable

        def initialize
          super :push
        end
      end

      # PullSockets are the counterpart of PushSockets (PUSH/PULL)
      class Pull < Socket
        include Readable

        def initialize
          super :pull
        end
      end

      # PubSockets are the counterpart of SubSockets (PUB/SUB)
      class Pub < Socket
        include Writable

        def initialize
          super :pub
        end
      end

      # XPubSockets are just like PubSockets but reading from them gives you the
      # subscription/unsubscription channels as they're joined/left.
      class XPub < Socket
        include Writable
        include Readable

        def initialize
          super :xpub
        end
      end

      # SubSockets are the counterpart of PubSockets (PUB/SUB)
      class Sub < Socket
        include Readable

        def initialize
          super :sub
        end

        def subscribe(topic)
          unless result_ok? @socket.setsockopt(::ZMQ::SUBSCRIBE, topic)
            raise IOError, "couldn't set subscribe: #{::ZMQ::Util.error_string}"
          end
        end

        def unsubscribe(topic)
          unless result_ok? @socket.setsockopt(::ZMQ::UNSUBSCRIBE, topic)
            raise IOError, "couldn't set unsubscribe: #{::ZMQ::Util.error_string}"
          end
        end
      end
    end
  end
end
