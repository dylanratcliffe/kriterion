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
        @client              = Mongo::Client.new(
          ["#{@hostname}:#{@port}"], database: @database
        )
        @standards_db        = @client[:standards]
        @standard_details_db = @client[:standard_details]
        # TODO: Work out how to set the mongo client logging level
      end

      def standards
        binding.pry
      end

      def standard(standard)
        # TODO: Complete this
        binding.pry
      end

      def get_standard(name)
        # TODO: Complete this
        result = standards_db.find(name: name)
        count  = result.count
        case count
        when 0
          nil
        when 1
          standard = result.first
          # Compile the regex from a lazy-compiled BSON regex back to a ruby one
          standard['item_syntax'] = standard['item_syntax'].compile
          Kriterion::Standard.new(standard)
        else
          raise "Found > 1 standards with name: #{name}"
        end
      end

      def add_standard(standard)
        result = standards_db.insert_one(standard.to_h)
        raise "Insertion of #{standard.name} failed" unless result.ok?
        standard
      end

      # def set_standard_details(name, standard)
      #   # TODO: Complete this
      # end
      #
      # def get_standard_details(name)
      #   # TODO: Complete this
      #   standard_details_db.find(name)
      # end
    end
  end
end
