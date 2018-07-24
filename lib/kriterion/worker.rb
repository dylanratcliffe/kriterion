require 'json'
require 'net/http'
require 'logger'
require 'kriterion'
require 'kriterion/logs'
require 'kriterion/report'
require 'kriterion/section'
require 'kriterion/standard'

require 'pry'

class Kriterion
  class Worker
    include Kriterion::Logs

    attr_reader :uri
    attr_reader :queue
    attr_reader :queue_uri
    attr_reader :standards
    attr_reader :backend

    def initialize(opts = {})
      logger.level = Kriterion::Logs::DEBUG if opts[:debug]

      # Set up connections
      @uri            = opts[:uri]
      @queue          = opts[:queue]
      @queue_uri      = URI("#{@uri}/q/#{@queue}")

      # Set up the backend
      # TODO: Clean this up and make fully dynamic
      backend_name    = opts[:backend] || 'mongodb'
      case backend_name
      when 'mongodb'
        require 'kriterion/backend/mongodb'
        Kriterion::Backend.set(
          Kriterion::Backend::MongoDB.new(
            hostname: opts[:mongo_hostname],
            port:     opts[:mongo_port],
            database: opts[:mongo_database]
          )
        )
      end

      @backend = Kriterion::Backend.get

      # TODO: Work out how workers are going to get the list of standards frmo the API runner
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

      # Process the report
      affected_standards = relevant_resources.group_by do |resource|
        # Select the standard tag
        stds = (resource.tags & standard_names)

        raise 'Found a resource that was relevant to more than one standard. This is not yet supported' if stds.length > 1

        stds[0]
      end

      affected_standards.each do |name, resources|
        standard = backend.get_standard(name)
        unless standard
          # If the standard doesn't yet exist in the backed, add it
          standard = Kriterion::Standard.new(@standards[name])
          logger.debug "Adding starndard #{standard.name} to backend"
          backend.add_standard(standard)
          # TODO: See if there is a better way to deal with this, the reason I'm
          # doing this is that I want to make sure that there is not difference
          # between a newly created object and one that came from the database
          standard = backend.get_standard(name)
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
          section  = captures.reduce(standard) do |previous, current|
            # If the section already exists return it
            if previous.find_section(current)
              previous.find_section(current)
            else
              # This is a new section that does not yet exist in the database,
              # we therefore need to get the details and all them all in
              current_section_name = if previous.is_a? Kriterion::Standard
                                       current
                                     elsif previous.is_a? Kriterion::Section
                                       [
                                         previous.name,
                                         current
                                       ].join(standard.section_separator)
                                     end

              # Get the details from the standards database (name, description
              # etc.)
              current_section = @standards[name]['sections'].select do |s|
                s['name'] == current_section_name
              end[0]

              if current_section.nil?
                previous
              else
                # Create the new section object
                current_section['standard']    = standard.name
                current_section['parent_type'] = previous.type
                current_section['parent_name'] = previous.name
                current_section = Kriterion::Section.new(current_section)

                # Add the section to the backend
                backend.add_section(current_section)
                current_section
              end
            end
          end

          # Add the resource to the section
          binding.pry
          backend.add_resource(section, resource)
        end

        # Reload the standard as new sections may have been added
        standard = backend.get_standard(name)

        # I have realised that adding something to a mongodb document that is
        # deeper than one level down is near impossible, so I'm going to need to
        # be a bit smarter about how I lay out this data. One giant hash is not
        # likely to work and I"m probably going to have to have many tables with
        # fields in each that reference their parent as per
        # https://docs.mongodb.com/manual/tutorial/model-tree-structures-with-parent-references/
        # The next thing to do is refactor the backend to fix all this. Thank
        # god there is even a concept of a backend so I dont' have to change the
        # workers.
        #
        # It's worth noting that it *could* probably be just one large hash if I
        # didn't have to deal with race conditions. Which I do

        binding.pry

        # Recalculate the compliance of a given standard once it is done
      end
    end

    def run
      while true do
        # Connect and check if there is anythong on the queue
        # TODO: Change this so that they listen properly
        logger.debug "GET #{queue_uri}"
        response = Net::HTTP.get_response(queue_uri)

        case response.code
        when '204'
          logger.debug 'Queue empty, sleeping...'
          sleep 3
        when '200'
          logger.debug 'Got a report, parsing...'
          report = JSON.parse(JSON.parse(response.body)['value'])
          logger.info "Report: transaction_uuid: #{report['transaction_uuid']}"
          process_report(report)
        end
      end
    end
  end
end
