require 'kriterion/object'

class Kriterion
  class Item < Kriterion::Object
    attr_reader :uuid
    attr_reader :id
    attr_reader :title
    attr_reader :description
    attr_reader :severity
    attr_reader :parent_uuid
    attr_reader :section_path

    attr_accessor :resources

    def initialize(data)
      @uuid         = data['uuid'] || SecureRandom.uuid
      @id           = data['id']
      @title        = data['title']
      @description  = data['description']
      @severity     = data['severity']
      @section_path = data['section_path']
      @parent_type  = data['parent_type']
      @parent_uuid  = data['parent_uuid']
      @resources    = data['resources'] || []
    end

    def compliance
      super(resources)
    end
  end
end
