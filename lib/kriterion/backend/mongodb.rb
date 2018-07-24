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
      attr_reader :sections_db
      attr_reader :items_db
      attr_reader :resources_db
      attr_reader :events_db
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
        @sections_db         = @client[:sections]
        @items_db            = @client[:items]
        @resources_db        = @client[:resources]
        @events_db           = @client[:events]
        @standard_details_db = @client[:standard_details]
        # TODO: Work out how to set the mongo client logging level
      end

      def standards
        binding.pry
      end

      def get_standard(name)
        sanitise_standard(find_standard(name))
      end

      def add_standard(standard)
        insert_into_db(@standards_db, standard)
      end

      def add_section(section)
        insert_into_db(@sections_db, section)
      end

      def add_item(section, item)
        insert_into_db(@items_db, item)
      end

      def add_resource(item, resource)
        insert_into_db(@resources_db, resource)
      end

      def add_event(resource, event)
        insert_into_db(@events_db, event)
      end
      # def add_section(section)
      #   query = {
      #     name: section.name,
      #     standard: section.standard
      #   }
      #   instruction = {
      #     '$addToSet' => {
      #       sections: section.to_h
      #     }
      #   }
      #   standards_db.update_one(query, instruction)
      # end

      # def add_resource(section, resource)
      #   standard = find_standard(section.standard)
      #   binding.pry
      # end
      # def set_standard_details(name, standard)
      #   # TODO: Complete this
      # end
      #
      # def get_standard_details(name)
      #   # TODO: Complete this
      #   standard_details_db.find(name)
      # end

      private

      def insert_into_db(database, thing)
        result = database.insert_one(thing.to_h)
        raise "Insertion of #{thing} failed" unless result.ok?
        thing
      end

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
