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
      @full_description  = "#{@certname}/#{@resource}/#{@property}: #{@message}"
    end

    def full_description
      # We want to update this when it is called to ensure it is up to date.
      # This could just be amethod instead of an instance variable but that
      # would mean that it wouldn't get stored in the database, which we want.
      @full_description = "#{@certname}/#{@resource}/#{@property}: #{@message}"
    end

    # Resources don't have compliance so we don't want this to do anything
    def compliance
      nil
    end

    def primary_key
      :full_description
    end
  end
end
