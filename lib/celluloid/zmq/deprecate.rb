module Celluloid
  module ZMQ
    ReadableSocket = Socket::Readable
    WritableSocket = Socket::Writable
    RepSocket = Socket::Rep
    ReqSocket = Socket::Req
    DealerSocket = Socket::Dealer
    RouterSocket = Socket::Router
    PushSocket = Socket::Push
    PullSocket = Socket::Pull
    PubSocket = Socket::Pub
    XPubSocket = Socket::XPub
    SubSocket = Socket::Sub
  end
end
