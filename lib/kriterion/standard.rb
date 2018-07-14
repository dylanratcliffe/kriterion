class Kriterion
  class Standard
    @@standards = []

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
      @name              = data['name']
      @date              = data['date']
      @description       = data['description']
      @title             = data['title']
      @version           = data['version']
      @item_syntax       = data['item_syntax']
      @section_separator = data['section_separator']
      @compliance        = data['compliance']
      @sections          = data['sections']
      @items             = data['items']
    end

    def run
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

    def to_h
      hash = {}

      self.instance_variables.each do |v|
        hash[v.to_s.gsub(%r{^@},'')] = self.instance_variable_get(v.to_s)
      end

      hash
    end
  end
end
