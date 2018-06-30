require 'kriterion/backend'
require 'kriterion/logs'
require 'mongo'
include Kriterion::Logs

class Kriterion
  class Backend
    class MongoDB < Kriterion::Backend
      attr_reader :hostname
      attr_reader :port
      attr_reader :database
      attr_reader :client

      def initialize(opts)
        logger.info 'Initializing MongoDB backend'

        @hostname = opts[:hostname]
        @port     = opts[:port]
        @database = opts[:database]
        @client   = Mongo::Client.new([ "#{@hostname}:#{@port}" ], :database => @database)
        # TODO: Work out how to set the mongo client logging level
      end

      def set_standard(name, standard)
        # TODO: Complete this
      end

      def get_standard(name)
        # TODO: Complete this
        client[:standards].find(name)
      end
    end
  end
end
