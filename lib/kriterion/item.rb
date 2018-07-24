class Kriterion
  class Item
    attr_reader :uuid
    attr_reader :id
    attr_reader :title
    attr_reader :description
    attr_reader :severity
    attr_reader :section_uuid
    attr_reader :section_path

    def intialize(data)
      @uuid         = data['uuid'] || SecureRandom.uuid
      @id           = data['id']
      @title        = data['title']
      @description  = data['description']
      @severity     = data['severity']
      @section_uuid = data['section_uuid']
      @section_path = data['section_path']
    end
  end
end
