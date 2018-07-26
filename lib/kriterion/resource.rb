require 'kriterion/object'
require 'json'

class Kriterion
  class Resource < Kriterion::Object
    attr_reader :uuid
    attr_reader :title
    attr_reader :file
    attr_reader :line
    attr_reader :resource
    attr_reader :resource_type
    attr_reader :provider_used
    attr_reader :containment_path
    attr_reader :tags

    attr_accessor :events
    attr_accessor :parent_uuid
    attr_accessor :unchanged_nodes

    def initialize(hash)
      @uuid             = hash['uuid'] || SecureRandom.uuid
      @title            = hash['title']
      @file             = hash['file']
      @line             = hash['line']
      @resource         = hash['resource']
      @resource_type    = hash['resource_type']
      @provider_used    = hash['provider_used']
      @containment_path = hash['containment_path']
      @tags             = hash['tags']
      @events           = hash['events'] || []
      @parent_uuid      = hash['parent_uuid']
      @unchanged_nodes  = hash['unchanged_nodes'] || []
    end

    def ==(other)
      other.resource == resource
    end

    def compliance
      compliant     = unchanged_nodes.count
      non_compliant = events.group_by(&:certname).count
      total         = compliant + non_compliant
      percentage    = if total.zero?
                        0
                      else
                        compliant / total
                      end

      {
        'compliant' => events.empty?,
        'events'    => {
          'percentage'    => percentage,
          'compliant'     => compliant,
          'non_compliant' => non_compliant,
          'total'         => total
        }
      }
    end
  end
end
