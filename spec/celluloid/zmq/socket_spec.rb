require 'celluloid/rspec'

RSpec.describe Celluloid::ZMQ::Socket, library: :ZMQ do

  it "allows setting and getting ZMQ options on the socket" do
    socket = Celluloid::ZMQ::Socket::Rep.new
    socket.set(::ZMQ::IDENTITY, "Identity")

    identity = socket.get(::ZMQ::IDENTITY)

    expect(identity).to eq("Identity")
    socket.close
  end

end
