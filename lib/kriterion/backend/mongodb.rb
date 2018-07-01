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
      attr_reader :standards_db
      attr_reader :standard_details_db

      def initialize(opts)
        logger.info 'Initializing MongoDB backend'

        @hostname            = opts[:hostname]
        @port                = opts[:port]
        @database            = opts[:database]
        @client              = Mongo::Client.new([ "#{@hostname}:#{@port}" ], :database => @database)
        @standards_db        = @client[:standards]
        @standard_details_db = @client[:standard_details]
        # TODO: Work out how to set the mongo client logging level
      end

      def set_standard(name, standard)
        # TODO: Complete this
      end

      def get_standard(name)
        # TODO: Complete this
        standards_db.find(name)
      end

      def set_standard_details(name, standard)
        # TODO: Complete this
      end

      def get_standard_details(name)
        # TODO: Complete this
        standard_details_db.find(name)
      end
    end
  end
end
