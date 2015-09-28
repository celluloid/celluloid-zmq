require "celluloid/rspec"

RSpec.describe Celluloid::ZMQ::Mailbox, library: :ZMQ do
  it_behaves_like "a Celluloid Mailbox"
end
