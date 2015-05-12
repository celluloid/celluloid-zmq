require 'celluloid/rspec'

RSpec.describe Celluloid::ZMQ::Socket, actor_system: :global do

  it "allows setting and getting ZMQ options on the socket" do
    socket = Celluloid::ZMQ::RepSocket.new
    socket.set(::ZMQ::IDENTITY, "Identity")

    identity = socket.get(::ZMQ::IDENTITY)

    expect(identity).to eq("Identity")
    socket.close
  end

  describe "with SNDTIMEO set" do
    describe "#write" do
      it "raises EAGAIN when socket's outbound buffer is full" do
        socket = Celluloid::ZMQ::DealerSocket.new
        socket.set(::ZMQ::SNDHWM, 1)
        socket.set(::ZMQ::SNDTIMEO, 10)
        socket.connect("inproc://nonexistentserver")
        socket.write("foo")
        expect { socket.write("bar") }.to raise_error(IO::EAGAINWaitWritable)
      end
    end
  end
end
