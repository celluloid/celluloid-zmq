module Celluloid
  module ZMQ
    # You can't wake the dead
    DeadWakerError = Class.new IOError

    # Wakes up sleepy threads so that they can check their mailbox
    # Works like a ConditionVariable, except it's implemented as a ZMQ socket
    # so that it can be multiplexed alongside other ZMQ sockets
    class Waker
      def initialize
        @sender   = ::CZTop::Socket::PAIR.new
        @receiver = ::CZTop::Socket::PAIR.new

        @addr = "inproc://waker-#{object_id}"
        @sender.bind @addr
        @receiver.connect @addr

        @sender_lock = Mutex.new
      end

      # Wakes up the thread that is waiting for this Waker
      def signal
        @sender_lock.synchronize do
          @sender.signal
        end
      rescue
        raise DeadWakerError, "error sending signal over ZMQ: #{$!.message}"
      end
      alias_method :wakeup, :signal

      # 0MQ socket to wait for messages on
      def socket
        @receiver
      end

      # Wait for another thread to signal this Waker
      def wait
        @receiver.wait
      rescue
        raise DeadWakerError, "error receiving signal over ZMQ: #{$!.message}"
      end

      # Clean up the IO objects associated with this waker
      def cleanup
        @sender_lock.synchronize { @sender.close rescue nil }
        @receiver.close rescue nil
        nil
      end
      alias_method :shutdown, :cleanup
    end
  end
end
