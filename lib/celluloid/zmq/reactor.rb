module Celluloid
  module ZMQ
    # React to incoming 0MQ and Celluloid events. This is kinda sorta supposed
    # to resemble the Reactor design pattern.
    class Reactor

      extend Forwardable
      def_delegator :@waker, :signal, :wakeup
      def_delegator :@waker, :cleanup, :shutdown

      def initialize
        @waker = Waker.new
        @poller = ::CZTop::Poller.new
        @readers = {}
        @writers = {}

        @poller.add_reader(@waker.socket)
      end

      # Wait for the given ZMQ socket to become readable
      def wait_readable(socket)
        monitor_zmq socket, @readers, :read
      end

      # Wait for the given ZMQ socket to become writable
      def wait_writable(socket)
        monitor_zmq socket, @writers, :write
      end

      # Monitor the given ZMQ socket with the given options
      def monitor_zmq(socket, set, type)
        if set.has_key? socket
          raise ArgumentError, "another method is already waiting on #{socket.inspect}"
        else
          set[socket] = Task.current
        end

        case type
        when :read
          @poller.add_reader(socket)
        when :write
          @poller.add_writer(socket)
        else
          raise ArgumentError, "wrong type: #{type.inspect}"
        end

        Task.suspend :zmqwait
        socket
      end

      # Run the reactor, waiting for events, and calling the given block if
      # the reactor is awoken by the waker
      def run_once(timeout = nil)
        if timeout
          timeout *= 1000 # Poller uses millisecond increments
        else
          timeout = 0 # blocking
        end

        begin
          @poller.wait(timeout)
        rescue
          raise IOError, "ZMQ poll error: #{$!.message}"
        end

        @poller.readables.each do |sock|
          if sock == @waker.socket
            @waker.wait
          else
            task = @readers.delete sock
            @poller.remove_reader(sock)

            if task
              task.resume
            else
              Celluloid::Logger.debug "ZMQ error: got read event without associated reader"
            end
          end
        end

        @poller.writables.each do |sock|
          task = @writers.delete sock
          @poller.remove_writer(sock)

          if task
            task.resume
          else
            Celluloid::Logger.debug "ZMQ error: got write event without associated writer"
          end
        end
      end
    end
  end
end
