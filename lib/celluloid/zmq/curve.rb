module Celluloid
  module ZMQ

    class Socket

      class << self

        def new_curve(options={})
          socket = new
          socket.extend Curve
          socket.init options
          socket
        end

        def new_client(socket)
          raise UninitializedError, "No server socket to create clients for." unless socket.server?
          new_curve socket.new_client
        end

        def new_server(options={})
          new_curve options.merge(:type=>server)
        end
      end

    end

    module Curve
    
      attr_accessor :curve

      def init(options)
        raise UninitializedError unless options.is_a? Hash
        @curve = options.inject({}) { |s,(k,v)| s[k.to_sym] = v; s }
        unless @curve[:type]
          if @curve[:server_public_key] and !@curve[:server_private_key]
            @curve[:type] = :client
          else
            @curve[:type] = :server
          end
        end

        Celluloid::Logger.info "CurveZMQ wrapper: #{@curve[:type]}"

        case @curve[:type]
        when :server
          unless @curve[:server_private_key]
            @curve[:server_public_key], @curve[:server_private_key] = generate_keypair
            Celluloid::Logger.info "generated keypair for CurveZMQ server wrapper"
            Celluloid::Logger.info "public key: #{@curve[:server_public_key]}"
            Celluloid::Logger.info "private key: #{@curve[:server_private_key]}"
          end
          set(::ZMQ::CURVE_SERVER, 1)
          set(::ZMQ::CURVE_SECRETKEY, @curve[:server_private_key])
        when :client
          raise UninitializedError, "No server public key provided to client." unless @curve[:server_public_key]
          unless @curve[:client_public_key] and @curve[:client_private_key]
            @curve[:client_public_key], @curve[:client_private_key] = generate_keypair
            Celluloid::Logger.info "generated keypair for CurveZMQ client wrapper"
            Celluloid::Logger.info "public key: #{@curve[:client_public_key]}"
            Celluloid::Logger.info "private key: #{@curve[:client_private_key]}"
          end
          set(::ZMQ::CURVE_SERVERKEY, @curve[:server_public_key])
          set(::ZMQ::CURVE_PUBLICKEY, @curve[:client_public_key])
          set(::ZMQ::CURVE_SECRETKEY, @curve[:client_private_key])
        else
          raise UninitializedError, "No curve socket type specified."
        end

      end
  
      def server?
        !@curve[:server_private_key].nil?
      end

      def new_client
        raise UninitializedError, "No server public key." unless @curve[:server_public_key]
        { :server_public_key => @curve[:server_public_key] }
      end

      def generate_keypair
        ::ZMQ::Util.curve_keypair
      end

    end
  end
end
