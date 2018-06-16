require 'json'
require 'mongo'
require 'kriterion/logs'
include Kriterion::Logs

class Kriterion
  class API
    attr_reader :mongo
    attr_reader :standards_dir

    def initialize(opts)
      if opts[:debug]
        logger.level = Kriterion::Logs::DEBUG
      end

      @mongo_hostname = opts[:mongo_hostname]
      @mongo_port     = opts[:mongo_port]
      @mongo_database = opts[:mongo_database]
      @mongo          = Mongo::Client.new([ "#{@mongo_hostname}:#{@mongo_port}" ], :database => @mongo_database)
      @standards_dir  = opts[:standards_dir]
    end

    def run
      # Find all standards and add them to mongodb
    end
  end
end
