require 'kriterion/object'

class Kriterion
  class Event < Kriterion::Object
    attr_reader :audited
    attr_reader :property
    attr_reader :previous_value
    attr_reader :desired_value
    attr_reader :historical_value
    attr_reader :message
    attr_reader :name
    attr_reader :status
    attr_reader :time
    attr_reader :redacted
    attr_reader :corrective_change

    attr_accessor :certname
    attr_accessor :resource

    def initialize(data)
      @audited           = data['audited']
      @property          = data['property']
      @previous_value    = data['previous_value']
      @desired_value     = data['desired_value']
      @historical_value  = data['historical_value']
      @message           = data['message']
      @name              = data['name']
      @status            = data['status']
      @time              = data['time']
      @redacted          = data['redacted']
      @corrective_change = data['corrective_change']
      @certname          = data['certname']
      @resource          = data['resource']
    end
  end
end
