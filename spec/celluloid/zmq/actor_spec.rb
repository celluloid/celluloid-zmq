require 'celluloid/rspec'

RSpec.describe Celluloid::ZMQ, library: :ZMQ do
  it_behaves_like "a Celluloid Actor", Celluloid::ZMQ
end
