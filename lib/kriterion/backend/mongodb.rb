require 'kriterion/resource'
require 'kriterion/standard'
require 'kriterion/section'
require 'kriterion/backend'
require 'kriterion/metrics'
require 'kriterion/event'
require 'kriterion/item'
require 'kriterion/logs'
require 'benchmark'
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
        super(opts)
        logger.info 'Initializing MongoDB backend'
        @hostname            = opts[:hostname]
        @port                = opts[:port]
        @database            = opts[:database]
        @client              = Mongo::Client.new(
          ["#{@hostname}:#{@port}"], database: @database
        )
        @client.logger.level = logger.level
        @standards_db        = @client[:standards]
        @sections_db         = @client[:sections]
        @items_db            = @client[:items]
        @resources_db        = @client[:resources]
        @events_db           = @client[:events]
        @standard_details_db = @client[:standard_details]
      end

      def find(type, query, opts)
        database_for(type).find(query).map do |result|
          # Sanitise the data if required
          params = sanitise_data(type, result)

          # Create the object and return in an array
          object = class_for(type).new(params)

          require 'pry'
          binding.pry
          # Find children if required
          find_children!(object) if opts[:recurse]

          object
        end
      end

      def insert(object)
        insert_into_db(database_for(object), object)
      end

      def add_unchanged_node(resource, certname)
        resources_db.update_one(
          { resource: resource.resource },
          '$addToSet' => {
            unchanged_nodes: certname
          }
        )
      end

      def update_compliance!(thing)
        database_for(thing).update_one(
          { uuid: thing.uuid },
          '$set' => {
            compliance: thing.compliance
          }
        )
      end

      def purge_events!(certname)
        # Delete all events for this certname
        events_db.delete_many(
          certname: certname
        )

        # Delete all instances of this certname under "unchanged_nodes"
        resources_db.update_many(
          {}, # Don't pass a query as we want to purge everything
          '$pull' => { # Remove this node from unchanged nodes
            unchanged_nodes: certname
          }
        )
      end

      private

      def sanitise_data(type, data)
        if type == :standard
          return nil if data.nil?
          # Compile the regex from a lazy-compiled BSON regex back to a ruby one
          data['item_syntax'] = data['item_syntax'].compile
        end
        data
      end

      # Returns the database for a given object type
      def database_for(object)
        cls = class_for(object)
        databases = {
          Kriterion::Standard => @standards_db,
          Kriterion::Section  => @sections_db,
          Kriterion::Item     => @items_db,
          Kriterion::Resource => @resources_db,
          Kriterion::Event    => @events_db
        }
        databases[cls]
      end

      def find_children!(object)
        accepted_objects = [
          Kriterion::Standard,
          Kriterion::Section,
          Kriterion::Item,
          Kriterion::Resource,
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
            resource = Kriterion::Resource.new(resource)
            find_children! resource
            object.resources << resource
          end
        when Kriterion::Resource
          result = events_db.find(
            resource: object.resource
          )

          result.each do |event|
            event = Kriterion::Event.new(event)
            find_children! event
            object.events << event
          end
        when Kriterion::Event
          nil
        else
          # We can safely assume this is a Kriterion::Standard or
          # Kriterion::Section, which are treated the same

          # Find all child sections and add them to the standard
          find_child_sections(object).each do |section|
            object.sections << section
            # Also recurse and find all children of each child we find
            find_children!(section)
          end

          # Find all direct child items
          find_child_items(object).each do |item|
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

      def find_child_items(parent)
        results = items_db.find(
          parent_type: parent.type,
          parent_uuid: parent.uuid
        )

        results.map do |item|
          Kriterion::Item.new(item)
        end
      end

      def find_child_sections(parent)
        result = sections_db.find(
          parent_type: parent.type,
          parent_uuid: parent.uuid
        )
        result.map do |section|
          Kriterion::Section.new(section)
        end
      end
    end
  end
end
