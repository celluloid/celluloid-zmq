module Celluloid
  module ZMQ
    # Replacement mailbox for Celluloid::ZMQ actors
    class Mailbox < Celluloid::Mailbox::Evented
      def initialize
        super(Reactor)
      end
    end
  end
end
