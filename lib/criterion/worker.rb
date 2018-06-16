require 'json'
require 'net/http'
require 'mongo'
require 'logger'
require 'kriterion/report'
require 'kriterion/logs'
include Kriterion::Logs

require 'pry'

class Kriterion
  class Worker
    attr_reader :uri
    attr_reader :queue
    attr_reader :queue_uri
    attr_reader :mongo

    def initialize(opts = {})
      if opts[:debug]
        logger.level = Kriterion::Logs::DEBUG
      end

      # Set up connections
      @uri            = opts[:uri]
      @queue          = opts[:queue]
      @queue_uri      = URI("#{@uri}/q/#{@queue}")
      @mongo_hostname = opts[:mongo_hostname]
      @mongo_port     = opts[:mongo_port]
      @mongo_database = opts[:mongo_database]
      @mongo          = Mongo::Client.new([ "#{@mongo_hostname}:#{@mongo_port}" ], :database => @mongo_database)
      # TODO: Work out how workers are going to get the list of standards frmo the API runner
      # TODO: Remove placeholder code
      @standards      = ['puppet_enterprise']
    end

    def process_report(report)
      report = Kriterion::Report.new(report)
      binding.pry
      puts report
    end

    def run
      while true do
        binding.pry
        # Connect and check if there is anythong on the queue
        # TODO: Change this so that they listen properly
        logger.debug "GET #{queue_uri}"
        response = Net::HTTP.get_response(queue_uri)

        case response.code
        when "204"
          logger.debug "Queue empty, sleeping..."
          sleep 3
        when "200"
          binding.pry
          logger.debug "Got a report, parsing..."
          report = JSON.parse(JSON.parse(response.body)['value'])
          logger.info "Report: transaction_uuid: #{report['transaction_uuid']}"
          process_report(report)
        end
      end
    end
  end
end
