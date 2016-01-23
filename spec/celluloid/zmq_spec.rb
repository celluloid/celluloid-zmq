RSpec.describe Celluloid::ZMQ do
  before { @sockets = [] }
  after { @sockets.each(&:close) }

  def connect(socket, index=0)
    socket.connect("inproc://celluloid-spec-#{index}")
    @sockets << socket
    socket
  end

  def bind(socket, index=0)
    socket.bind("inproc://celluloid-spec-#{index}")
    @sockets << socket
    socket
  end

  describe ".init" do
    # deprecated
  end

  describe Celluloid::ZMQ::Socket::Rep do
    let(:actor) do
      Class.new do
        include Celluloid::ZMQ

        finalizer :close_socket

        def initialize(index)
          @socket = Celluloid::ZMQ::Socket::Rep.new
          @socket.connect("inproc://celluloid-spec-#{index}")
        end

        def say_hi
          "Hi!"
        end

        def fetch
          @socket.read
        end

        def close_socket
          @socket.close
        end
      end
    end

    it "receives messages" do
      server = bind(CZTop::Socket::REQ.new)
      client = actor.new(0)

      server << "hello world"
      result = client.fetch
      expect(result).to eq("hello world")
    end

    it "suspends actor while waiting for message" do
      server = bind(CZTop::Socket::REQ.new)
      client = actor.new(0)

      result = client.future.fetch
      expect(client.say_hi).to eq("Hi!")
      server << "hello world"
      expect(result.value).to eq("hello world")
    end
  end

  describe Celluloid::ZMQ::Socket::Req do
    let(:actor) do
      Class.new do
        include Celluloid::ZMQ

        finalizer :close_socket

        def initialize(index)
          @socket = Celluloid::ZMQ::Socket::Req.new
          @socket.connect("inproc://celluloid-spec-#{index}")
        end

        def say_hi
          "Hi!"
        end

        def send(message)
          @socket.write(message)
          true
        end

        def close_socket
          @socket.close
        end
      end
    end

    it "sends messages" do
      client = bind(CZTop::Socket::REP.new)
      server = actor.new(0)

      server.send("hello world")

      message = client.receive[0].to_s
      expect(message).to eq("hello world")
    end

    it "suspends actor while waiting for message to be sent" do
      client = bind(CZTop::Socket::REP.new)
      server = actor.new(0)

      result = server.future.send("hello world")

      expect(server.say_hi).to eq("Hi!")

      message = client.receive[0].to_s
      expect(message).to eq("hello world")

      expect(result.value).to be_truthy
    end
  end
end
