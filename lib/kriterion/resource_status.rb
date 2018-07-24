require 'json'

class Kriterion
  class ResourceStatus
    attr_reader :title
    attr_reader :file
    attr_reader :line
    attr_reader :resource
    attr_reader :resource_type
    attr_reader :provider_used
    attr_reader :containment_path
    attr_reader :evaluation_time
    attr_reader :tags
    attr_reader :time
    attr_reader :failed
    attr_reader :changed
    attr_reader :out_of_sync
    attr_reader :skipped
    attr_reader :change_count
    attr_reader :out_of_sync_count
    attr_reader :events
    attr_reader :corrective_change

    def initialize(hash)
      @title             = hash['title']
      @file              = hash['file']
      @line              = hash['line']
      @resource          = hash['resource']
      @resource_type     = hash['resource_type']
      @provider_used     = hash['provider_used']
      @containment_path  = hash['containment_path']
      @evaluation_time   = hash['evaluation_time']
      @tags              = hash['tags']
      @time              = hash['time']
      @failed            = hash['failed']
      @changed           = hash['changed']
      @out_of_sync       = hash['out_of_sync']
      @skipped           = hash['skipped']
      @change_count      = hash['change_count']
      @out_of_sync_count = hash['out_of_sync_count']
      @events            = hash['events']
      @corrective_change = hash['corrective_change']
      @standard          = hash['standard']
      @item              = hash['item']
    end

    def compliant?
      @out_of_sync_count.zero? && @change_count.zero?
    end
  end
end
