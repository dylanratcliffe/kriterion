require 'json'
require 'net/http'
require 'mongo'
require 'logger'
require 'criterion/report'
require 'criterion/logs'
include Criterion::Logs

require 'pry'

class Criterion
  class Worker
    attr_reader :uri
    attr_reader :queue
    attr_reader :queue_uri
    attr_reader :mongo

    def initialize(opts = {})
      if opts[:debug]
        logger.level = Criterion::Logs::DEBUG
      end

      # Set up connections
      @uri            = opts[:uri]
      @queue          = opts[:queue]
      @queue_uri      = URI("#{@uri}/q/#{@queue}")
      @mongo_hostname = opts[:mongo_hostname]
      @mongo_port     = opts[:mongo_port]
      @mongo_database = opts[:mongo_database]
      @mongo          = Mongo::Client.new([ "#{@mongo_hostname}:#{@mongo_port}" ], :database => @mongo_database)
    end

    def process_report(report)
      report = Criterion::Report.new(report)
      binding.pry
      puts report
    end

    def run
      while true do
        binding.pry
        # Connect and check if there is anythong on the queue
        # TODO: Change thos so that they listen properly
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
