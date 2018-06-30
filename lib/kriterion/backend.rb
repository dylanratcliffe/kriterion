class Kriterion
  class Backend
    # A backend should implement the following methods:
    #
    #  - get_standard(name)
    #  - set_standard(name, standard)
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
