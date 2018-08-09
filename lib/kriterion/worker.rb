require 'json'
require 'net/http'
require 'benchmark'
require 'kriterion'
require 'kriterion/item'
require 'kriterion/report'
require 'kriterion/metrics'
require 'kriterion/section'
require 'kriterion/standard'
require 'kriterion/connector'

require 'pry'

class Kriterion
  class Worker
    include Kriterion::Logs
    include Kriterion::Connector

    attr_reader :queue_uri
    attr_reader :standards
    attr_reader :backend
    attr_reader :metrics

    def initialize(opts = {})
      @queue_uri, @metrics, @backend = Kriterion::Connector.connections(opts)

      # TODO: Work out how workers are going to get the list of standards frmo
      # the API runner
      # TODO: Remove placeholder code
      standards_dir   = File.expand_path('standards', Kriterion::ROOT)
      @standards      = Kriterion.standards([standards_dir])
    end

    def process_report(report)
      report = Kriterion::Report.new(report)

      # Check if the report contains any relevant resources
      standard_names     = standards.keys
      relevant_resources = report.resources_with_tags(standard_names)

      return nil if relevant_resources.empty?

      logger.info "Processing report with #{relevant_resources.count} relevant resources"

      # Purge all old events relevant to this node, they will be re-added
      backend.purge_events! report.certname

      # Process the report
      affected_standards = relevant_resources.group_by do |resource|
        # Select the standard tag
        stds = (resource.tags & standard_names)

        raise 'Found a resource that was relevant to more than one standard. This is not yet supported' if stds.length > 1

        stds[0]
      end

      affected_standards.each do |name, resources|
        standard = backend.get_standard(name, recurse: true)
        unless standard
          # If the standard doesn't yet exist in the backed, add it
          standard = Kriterion::Standard.new(@standards[name])
          logger.debug "Adding starndard #{standard.name} to backend"
          backend.ensure_standard(standard)
          # TODO: See if there is a better way to deal with this, the reason I'm
          # doing this is that I want to make sure that there is not difference
          # between a newly created object and one that came from the database
          standard = backend.get_standard(name, recurse: true)
        end

        resources.each do |resource|
          # Get the section tag
          section_tag = resource.tags.select do |t|
            standard.item_syntax.match(t)
          end

          # TODO: Make this work
          raise 'Found a resource relevant to multiple sections' if section_tag.length > 1

          section_tag = section_tag.first

          # Go though all sections and subsections and create them if required
          captures = standard.item_syntax.match(section_tag).captures - [nil]

          # Convert the captures to a list of sections, but excluse the last one
          # because that will be the name of the item
          parent_sections = captures_to_sections(standard, captures[0..-2])

          # If there are no captures then this is a direct child of a standard
          if captures.nil?
            section = standard
          else
            section = parent_sections.reduce(standard) do |previous, current|
              # If the section already exists return it
              if previous.find_section(current)
                previous.find_section(current)
              else
                # Get the details from the standards database (name, description
                # etc.)
                current_section = @standards[name]['sections'].select do |s|
                  s['name'] == current
                end[0]

                if current_section.nil?
                  previous
                else
                  # Create the new section object
                  current_section['standard']    = standard.name
                  current_section['parent_type'] = previous.type
                  current_section['parent_uuid'] = previous.uuid
                  current_section = Kriterion::Section.new(current_section)

                  # Add the section to the backend
                  backend.ensure_section(current_section)
                  current_section
                end
              end
            end
          end

          # Create and add the item if it doesn't yet exist
          item = case section.items.select { |i| i.id == section_tag }.count
                 when 1
                   # The item already exists, return it
                   section.items.select { |i| i.id == section_tag }[0]
                 when 0
                   # The item does not exist, create it, add to the database,
                   # then return it
                   item_details = @standards[name]['items'].select do |i|
                     i['id'].upcase == section_tag.upcase
                   end[0]
                   item_details['parent_uuid']  = section.uuid
                   item_details['parent_type']  = section.type
                   item_details['section_path'] = captures
                   backend.ensure_item(Kriterion::Item.new(item_details))
                 else
                   raise "Found muliple sections with the id #{section_tag}"
                 end

          # Add extra contextual data to that resource
          resource.parent_uuid = item.uuid

          # Add the new resource to the backend if it doesn't exist
          unless item.resources.include? resource
            item.resources << resource
            backend.ensure_resource(resource)
          end

          # Inform the database that this node is unchanged if we have no events
          if resource.events.empty?
            backend.add_unchanged_node(resource, report.certname)
          end

          # Add all events to the database
          resource.events = resource.events.map do |event|
            event          = Kriterion::Event.new(event)
            event.certname = report.certname
            event.resource = resource.resource
            backend.add_event(event)
            event
          end
        end

        # Reload the standard as new sections may have been added
        standard = backend.get_standard(name, recurse: true)

        metrics[:update_compliance] += Benchmark.realtime do
          # Recalculate the compliance of a given standard once it is done (This
          # also calculates the compliacne of all children and yeilds them to
          # block)
          standard.flush_compliance! do |child|
            backend.update_compliance! child
          end
        end
      end
    end

    def run
      while true do
        # Connect and check if there is anythong on the queue
        # TODO: Change this so that they listen properly
        logger.debug "GET #{queue_uri}"
        begin
          response = Net::HTTP.get_response(queue_uri)

          case response.code
          when '204'
            logger.debug 'Queue empty, sleeping...'
            sleep 3
          when '200'
            logger.debug 'Got a report, parsing...'
            report = JSON.parse(JSON.parse(response.body)['value'])
            logger.info "Processing report: #{report['host']} #{report['time']}"

            metrics[:total_processing] += Benchmark.realtime do
              process_report(report)
            end

            metrics.print
            metrics.reset!
          end
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
               Net::ProtocolError, Errno::ECONNREFUSED, SocketError => e
          logger.error "Error while running: #{e}"
          logger.info 'Sleeping...'
          sleep 3
        end
      end
    end

    private

    def captures_to_sections(standard, captures)
      sections = []

      captures.each_index do |index|
        sections << captures[0..index].join(standard.section_separator)
      end

      sections
    end
  end
end
