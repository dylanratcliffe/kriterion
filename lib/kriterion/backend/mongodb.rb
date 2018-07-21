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
        sanitise_standard(find_standard(name))
      end

      def add_standard(standard)
        result = standards_db.insert_one(standard.to_h)
        raise "Insertion of #{standard.name} failed" unless result.ok?
        standard
      end

      def add_section(section)
        query       = { name: section.standard }
        instruction = {
          '$addToSet' => {
            sections: section.to_h
          }
        }
        standards_db.update_one(query, instruction)
      end

      def add_resource(section, resource)
        standard = find_standard(section.standard)
        binding.pry
      end
      # def set_standard_details(name, standard)
      #   # TODO: Complete this
      # end
      #
      # def get_standard_details(name)
      #   # TODO: Complete this
      #   standard_details_db.find(name)
      # end

      private

      def find_standard(name)
        result = standards_db.find(name: name)
        count  = result.count
        case count
        when 0
          nil
        when 1
          result.first
        else
          raise "Found > 1 standards with name: #{name}"
        end
      end

      # Takes a result and sanities it to Kriterion::Standard object
      def sanitise_standard(result)
        return nil if result.nil?
        # Compile the regex from a lazy-compiled BSON regex back to a ruby one
        result['item_syntax'] = result['item_syntax'].compile
        # Convert sections to objects
        if result['sections']
          result['sections'] = result['sections'].map do |s|
            Kriterion::Section.new(s)
          end
        end
        Kriterion::Standard.new(result)
      end
    end
  end
end
