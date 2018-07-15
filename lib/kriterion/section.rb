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

    def initialize(data, parent = nil)
      @uuid        = data['uuid'] || SecureRandom.uuid
      @name        = data['name']
      @standard    = data['standard']
      @description = data['description']
      @items       = data['items']
      @sections    = data['sections']
      parent.sections << self if parent
    end
  end
end
