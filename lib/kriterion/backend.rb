class Kriterion
  class Backend
    # A backend should implement the following methods:
    #
    #  - get_standard(name)
    #  - set_standard(name, standard)
    def standard_details
      def []=(name, standard)
        set_standard_details(name, standard)
      end

      def [](name)
        get_standard_details(name)
      end
    end

    def standards
      def []=(name, standard)
        set_standard(name, standard)
      end

      def [](name)
        get_standard(name)
      end
    end
  end
end
