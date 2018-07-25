require 'kriterion/resource_status'
require 'kriterion/standard'
require 'kriterion/section'
require 'kriterion/backend'
require 'kriterion/event'
require 'kriterion/item'
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

      def get_standard(name, opts = {})
        # Set recursion to false by default
        opts[:recurse] = opts[:recurse] || false

        standard = sanitise_standard(find_standard(name))
        return nil if standard.nil?

        if opts[:recurse]
          find_children!(standard)
          standard
        else
          standard
        end
      end

      def add_standard(standard)
        insert_into_db(standards_db, standard)
      end

      def add_section(section)
        insert_into_db(sections_db, section)
      end

      def add_item(item)
        insert_into_db(items_db, item)
      end

      def add_resource(resource)
        insert_into_db(resources_db, resource)
      end

      def add_event(event)
        insert_into_db(events_db, event)
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

      def find_children!(object)
        accepted_objects = [
          Kriterion::Standard,
          Kriterion::Section,
          Kriterion::Item,
          Kriterion::ResourceStatus,
          Kriterion::Event
        ]

        unless accepted_objects.include?(object.class)
          raise "Unsupported object type #{object.class.name}"
        end

        case object
        when Kriterion::Item
          result = resources_db.find(
            parent_uuid: object.uuid
          )

          result.each do |resource|
            res = Kriterion::ResourceStatus.new(resource)
            find_children!(res)
            object.resources << res
          end
        when Kriterion::ResourceStatus
          # TODO: Implement
          binding.pry
        when Kriterion::Event
          # TODO: Implement
          binding.pry
        else
          # We can safely assume this is a Kriterion::Standard or
          # Kriterion::Section, which are treated the same

          # Find all child sections and add them to the standard
          find_sections(object).each do |section|
            object.sections << section
            # Also recurse and find all children of each child we find
            find_children!(section)
          end

          # Find all direct child items
          find_items(object).each do |item|
            object.items << item
            find_children!(item)
          end
        end
      end

      def insert_into_db(database, thing)
        result = database.insert_one(thing.to_h)
        raise "Insertion of #{thing} failed" unless result.ok?
        thing
      end

      def find_items(parent)
        results = items_db.find(
          parent_type: parent.type,
          parent_uuid: parent.uuid
        )
        results.each do |item|
          Kriterion::Item.new(item)
        end
      end

      def find_sections(parent)
        result = sections_db.find(
          parent_type: parent.type,
          parent_uuid: parent.uuid
        )
        result.map do |section|
          Kriterion::Section.new(section)
        end
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
        Kriterion::Standard.new(result)
      end
    end
  end
end
