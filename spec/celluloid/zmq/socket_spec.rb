require "celluloid/rspec"

RSpec.describe Celluloid::ZMQ::Socket, library: :ZMQ do
  it "allows setting and getting ZMQ identity on the socket" do
    socket = Celluloid::ZMQ::Socket::Rep.new
    socket.identity = "Identity"

    identity = socket.identity

    expect(identity).to eq("Identity")
    socket.close
  end
end
