require 'kriterion/object'

class Kriterion
  class Event < Kriterion::Object
    attr_reader :new_value
    attr_reader :report
    attr_reader :corrective_change
    attr_reader :run_start_time
    attr_reader :property
    attr_reader :file
    attr_reader :old_value
    attr_reader :containing_class
    attr_reader :line
    attr_reader :resource_type
    attr_reader :status
    attr_reader :configuration_version
    attr_reader :resource_title
    attr_reader :environment
    attr_reader :timestamp
    attr_reader :run_end_time
    attr_reader :report_receive_time
    attr_reader :containment_path
    attr_reader :certname
    attr_reader :message

    def initialize(data)
      @new_value             = data['new_value']
      @report                = data['report']
      @corrective_change     = data['corrective_change']
      @run_start_time        = data['run_start_time']
      @property              = data['property']
      @file                  = data['file']
      @old_value             = data['old_value']
      @containing_class      = data['containing_class']
      @line                  = data['line']
      @resource_type         = data['resource_type']
      @status                = data['status']
      @configuration_version = data['configuration_version']
      @resource_title        = data['resource_title']
      @environment           = data['environment']
      @timestamp             = data['timestamp']
      @run_end_time          = data['run_end_time']
      @report_receive_time   = data['report_receive_time']
      @containment_path      = data['containment_path']
      @certname              = data['certname']
      @message               = data['message']
    end

    def compliant?
      lookup_table = {
        'changed' => false,
      }

      binding.pry
      # TODO: Find all possible statuses
      lookup_table[status]
    end
  end
end
