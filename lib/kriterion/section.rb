require 'securerandom'
require 'kriterion/object'

class Kriterion
  class Section < Kriterion::Object
    attr_accessor :uuid
    attr_accessor :name
    attr_accessor :standard
    attr_accessor :description
    attr_accessor :items
    attr_accessor :sections

    def initialize(data)
      @uuid        = data['uuid'] || SecureRandom.uuid
      @name        = data['name']
      @standard    = data['standard']
      @description = data['description']
      @items       = data['items']
      @sections    = data['sections']
      @parent_type = data['parent_type']
      @parent_name = data['parent_name']
    end

    def type
      :section
    end
  end
end
