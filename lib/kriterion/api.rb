require 'json'
require 'sinatra/base'
require 'kriterion/logs'
require 'kriterion/connector'

require 'pry'

class Kriterion
  class API < Sinatra::Application
    attr_accessor :queue_uri
    attr_accessor :metrics
    attr_accessor :backend

    include Kriterion::Logs

    # We only every want to have one instance of this running at a time. This is
    # required due to the way that Sinatra initialises things This adds the
    # initialize method etc.
    @@instance = nil

    def initialize(opts = {})
      # If there is already an instance, copy the objects from that
      if @@instance
        @queue_uri = @@instance.queue_uri
        @metrics   = @@instance.metrics
        @backend   = @@instance.backend
      else
        @queue_uri, @metrics, @backend = Kriterion::Connector.connections(opts)
        @@instance = self
      end
      super()
    end

    set :bind, '0.0.0.0'

    get '/standards/:name' do |name|
      backend.get_standard(name, recurse: true).to_h(:full).to_json
    end
  end
end
