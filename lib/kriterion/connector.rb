require 'kriterion/logs'
require 'kriterion/metrics'
require 'kriterion/backend'
require 'kriterion/backend/mongodb'

class Kriterion
  module Connector
    def self.connections(opts = {})
      logger.level = if opts[:debug]
                       Kriterion::Logs::DEBUG
                     else
                       Kriterion::Logs::INFO
                     end

      # Set up connections
      uri       = opts[:uri]
      queue     = opts[:queue]
      queue_uri = URI("#{uri}/q/#{queue}")
      metrics   = Kriterion::Metrics.new

      # Set up the backend
      # TODO: Clean this up and make fully dynamic
      backend_name = opts[:backend] || 'mongodb'
      case backend_name
      when 'mongodb'
        require 'kriterion/backend/mongodb'
        Kriterion::Backend.set(
          Kriterion::Backend::MongoDB.new(
            hostname: opts[:mongo_hostname],
            port:     opts[:mongo_port],
            database: opts[:mongo_database],
            metrics:  metrics
          )
        )
      end

      backend = Kriterion::Backend.get

      [queue_uri, metrics, backend]
    end
  end
end
