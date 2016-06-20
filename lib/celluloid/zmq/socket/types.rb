module Celluloid
  module ZMQ
    class Socket
      # ReqSockets are the counterpart of RepSockets (REQ/REP)
      class Req < Socket
        include Readable
        include Writable

        def initialize
          super :REQ
        end
      end

      # RepSockets are the counterpart of ReqSockets (REQ/REP)
      class Rep < Socket
        include Readable
        include Writable

        def initialize
          super :REP
        end
      end

      # DealerSockets are like ReqSockets but more flexible
      class Dealer < Socket
        include Readable
        include Writable

        def initialize
          super :DEALER
        end
      end

      # RouterSockets are like RepSockets but more flexible
      class Router < Socket
        include Readable
        include Writable

        def initialize
          super :ROUTER
        end
      end

      # PushSockets are the counterpart of PullSockets (PUSH/PULL)
      class Push < Socket
        include Writable

        def initialize
          super :PUSH
        end
      end

      # PullSockets are the counterpart of PushSockets (PUSH/PULL)
      class Pull < Socket
        include Readable

        def initialize
          super :PULL
        end
      end

      # PubSockets are the counterpart of SubSockets (PUB/SUB)
      class Pub < Socket
        include Writable

        def initialize
          super :PUB
        end
      end

      # XPubSockets are just like PubSockets but reading from them gives you the
      # subscription/unsubscription channels as they're joined/left.
      class XPub < Socket
        include Writable
        include Readable

        def initialize
          super :XPUB
        end
      end

      # SubSockets are the counterpart of PubSockets (PUB/SUB)
      class Sub < Socket
        include Readable

        def initialize
          super :SUB
        end

        def subscribe(topic)
          @socket.subscribe(topic)
        rescue
          raise IOError, "couldn't set subscribe: #{$!.message}"
        end

        def unsubscribe(topic)
          @socket.unsubscribe(topic)
        rescue
          raise IOError, "couldn't set unsubscribe: #{$!.message}"
        end
      end
    end
  end
end
