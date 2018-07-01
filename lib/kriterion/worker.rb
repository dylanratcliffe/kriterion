require 'json'
require 'net/http'
require 'logger'
require 'kriterion'
require 'kriterion/report'
require 'kriterion/logs'
include Kriterion::Logs

require 'pry'

class Kriterion
  class Worker
    attr_reader :uri
    attr_reader :queue
    attr_reader :queue_uri
    attr_reader :standards
    attr_reader :backend

    def initialize(opts = {})
      if opts[:debug]
        logger.level = Kriterion::Logs::DEBUG
      end

      # Set up connections
      @uri            = opts[:uri]
      @queue          = opts[:queue]
      @queue_uri      = URI("#{@uri}/q/#{@queue}")

      # Set up the backend
      # TODO: Clean this up and make fully dynamic
      backend_name    = opts[:backend] || 'mongodb'
      case backend_name
      when 'mongodb'
        require "kriterion/backend/mongodb"
        @backend = Kriterion::Backend::MongoDB.new({
                     hostname: opts[:mongo_hostname],
                     port:     opts[:mongo_port],
                     database: opts[:mongo_database],
                   })
      end

      # TODO: Work out how workers are going to get the list of standards frmo the API runner
      # TODO: Remove placeholder code
      standards_dir   = File.expand_path('standards',Kriterion::ROOT)
      @standards      = Kriterion.standards([standards_dir])
    end

    def process_report(report)
      report = Kriterion::Report.new(report)

      # Check if the report contains any relevant resources
      standard_names = self.standards.keys
      relevant_resources = report.resources_with_tags(standard_names)

      if relevant_resources.empty?
        return nil
      else
        # Process the report
        affected_standards = relevant_resources.group_by do |resource|
          # Select the standard tag
          stds = (resource.tags & standard_names)

          if stds.length > 1
            raise "Found a resource that was relevant to more than one standard. This is not yet supported"
          else
            stds[0]
          end
        end

        affected_standards.each do |name,resources|
          binding.pry
          # Check if the standard has been populated
          unless backend.standards[name]
            details = backend.standard_details[name]

          end
        end
      end
    end

    def run
      while true do
        # Connect and check if there is anythong on the queue
        # TODO: Change this so that they listen properly
        logger.debug "GET #{queue_uri}"
        response = Net::HTTP.get_response(queue_uri)

        case response.code
        when "204"
          logger.debug "Queue empty, sleeping..."
          sleep 3
        when "200"
          logger.debug "Got a report, parsing..."
          report = JSON.parse(JSON.parse(response.body)['value'])
          logger.info "Report: transaction_uuid: #{report['transaction_uuid']}"
          process_report(report)
        end
      end
    end
  end
end
