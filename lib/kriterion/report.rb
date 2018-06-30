require 'json'
require 'kriterion/resource_status'

class Kriterion
  class Report
    attr_reader :host
    attr_reader :time
    attr_reader :configuration_version
    attr_reader :transaction_uuid
    attr_reader :report_format
    attr_reader :puppet_version
    attr_reader :status
    attr_reader :transaction_completed
    attr_reader :noop
    attr_reader :noop_pending
    attr_reader :environment
    attr_reader :logs
    attr_reader :metrics
    attr_reader :corrective_change
    attr_reader :catalog_uuid
    attr_reader :code_id
    attr_reader :cached_catalog_status

    def initialize(data)
      @host                  = data['host']
      @time                  = data['time']
      @configuration_version = data['configuration_version']
      @transaction_uuid      = data['transaction_uuid']
      @report_format         = data['report_format']
      @puppet_version        = data['puppet_version']
      @status                = data['status']
      @transaction_completed = data['transaction_completed']
      @noop                  = data['noop']
      @noop_pending          = data['noop_pending']
      @environment           = data['environment']
      @logs                  = data['logs']
      @metrics               = data['metrics']
      @resource_statuses     = data['resource_statuses']
      @corrective_change     = data['corrective_change']
      @catalog_uuid          = data['catalog_uuid']
      @code_id               = data['code_id']
      @cached_catalog_status = data['cached_catalog_status']
    end

    def resource_statuses
      # If this is a hash then the objects haven't been initialised
      # We should initialise them now
      if @resource_statuses.is_a? Hash
        @resource_statuses = @resource_statuses.map do |ref, params|
          Kriterion::ResourceStatus.new(params)
        end
      end
      return @resource_statuses
    end

    # Returns resources that have given tags, expects an array of tags
    def resources_with_tags(tags)
      resource_statuses.select do |resource|
        tags.any? do |tag|
          resource.tags.include? tag
        end
      end
    end

  end
end
