
require 'kriterion/object'

class Kriterion
  class Standard < Kriterion::Object
    @@standards = []

    attr_accessor :uuid
    attr_accessor :name
    attr_accessor :date
    attr_accessor :description
    attr_accessor :title
    attr_accessor :version
    attr_accessor :item_syntax
    attr_accessor :section_separator
    attr_accessor :compliance
    attr_accessor :sections
    attr_accessor :items

    def initialize(data)
      @uuid              = data['uuid'] || SecureRandom.uuid
      @name              = data['name']
      @date              = data['date']
      @description       = data['description']
      @title             = data['title']
      @version           = data['version']
      @item_syntax       = if data['item_syntax'].is_a? Regexp
                             data['item_syntax']
                           else
                             Regexp.new(data['item_syntax'])
                           end
      @section_separator = data['section_separator']
      @compliance        = data['compliance']
      @sections          = data['sections'] || []
      @items             = data['items'] || []
    end

    def self.get(name)
      # Reload all standards
      Kriterion::Standard.reload_all!

      results = @@standards.select { |s| s.name == name }

      case results.length
      when 0
        raise "No standards found with name: #{name}"
      when 1
        results.first
      else
        raise "Multiple standards found with #{name}"
      end
    end

    def self.reload_all!
      backend = Kriterion::Backend.get
      @@standards = backend.standards
    end

    def type
      :standard
    end
  end
end
