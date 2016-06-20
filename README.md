![Celluloid::ZMQ](https://github.com/celluloid/celluloid-zmq/raw/master/logo.png)
=================
[![Gem Version](https://badge.fury.io/rb/celluloid-zmq.png)](http://rubygems.org/gems/celluloid-zmq)
[![Build Status](https://secure.travis-ci.org/celluloid/celluloid-zmq.png?branch=master)](http://travis-ci.org/celluloid/celluloid-zmq)
[![Code Climate](https://codeclimate.com/github/celluloid/celluloid-zmq.png)](https://codeclimate.com/github/celluloid/celluloid-zmq)
[![Coverage Status](https://coveralls.io/repos/celluloid/celluloid-zmq/badge.png?branch=master)](https://coveralls.io/r/celluloid/celluloid-zmq)

`Celluloid::ZMQ` provides Celluloid actors that can interact with [0MQ sockets][0mq].
Underneath, it's built on the [CZTop][cztop] library. `Celluloid::ZMQ` was
primarily created for the purpose of writing [DCell][dcell], distributed Celluloid
over 0MQ, so before you go building your own distributed Celluloid systems with
`Celluloid::ZMQ`, be sure to give DCell a look and decide if it fits your purposes.

[0mq]: http://www.zeromq.org/
[cztop]: https://github.com/paddor/cztop
[dcell]: https://github.com/celluloid/dcell

It provides different `Celluloid::ZMQ::Socket` classes which can be initialized
then sent `bind` or `connect`. Once bound or connected, the socket can
`read` or `send` depending on whether it's readable or writable.

## Supported Platforms

You will need the ZeroMQ library and the CZMQ library installed as it's
accessed via FFI. See [CZTop][cztop] for installation instructions.

Supported Rubies are MRI >= 2.2, JRuby >= 9.0.4.0, and Rubinius >= 3.7.

## 0MQ Socket Types

The following 0MQ socket types are supported (see [types.rb][types] for more info)

[types]: https://github.com/celluloid/celluloid-zmq/blob/master/lib/celluloid/zmq/socket/types.rb

* Req / Rep
* Push / Pull
* Pub / Sub
* Dealer / Router

## Usage

```ruby
require 'celluloid/zmq'

class Server
  include Celluloid::ZMQ

  def initialize(address)
    @socket = Socket::Pull.new

    begin
      @socket.bind(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def run
    loop { async.handle_message @socket.read }
  end

  def handle_message(message)
    puts "got message: #{message}"
  end
end

class Client
  include Celluloid::ZMQ

  def initialize(address)
    @socket = Socket::Push.new

    begin
      @socket.connect(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def write(message)
    @socket << message
    nil
  end
end

addr = 'tcp://127.0.0.1:3435'

server = Server.new(addr)
client = Client.new(addr)

server.async.run
client.write('hi')

sleep
```

Copyright
---------

Copyright (c) 2014-2015 Tony Arcieri, Donovan Keme.

Distributed under the MIT License. See [LICENSE.txt](https://github.com/celluloid/celluloid/blob/master/LICENSE.txt) for further details.
