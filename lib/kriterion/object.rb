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

    def compliance(objects)
      total         = objects.count
      compliant     = objects.count { |o| o.compliance['compliant'] }
      non_compliant = total - compliant
      percentage    = if total.zero?
                        0
                      else
                        compliant / total
                      end

      {
        'compliant' => percentage == 1,
        'events'    => {
          'percentage'    => percentage,
          'compliant'     => compliant,
          'non_compliant' => non_compliant,
          'total'         => total
        }
      }
    end
  end
end
