class Kriterion
  class Object
    def to_h(mode = :basic)
      raise 'Mode must be :basic or :full' unless %i[basic full].include? mode
      hash = {}

      instance_variables.each do |v|
        hash[v.to_s.gsub(/^@/, '')] = instance_variable_get(v.to_s)
      end

      if mode == :basic
        hash.reject do |k, _v|
          %w[
            sections
            items
            resources
            events
          ].include? k
        end
      elsif mode == :full
        hash
      end
    end

    def find_section(name)
      sections ? sections.select { |s| s.name == name }[0] : nil
    end
  end
end
