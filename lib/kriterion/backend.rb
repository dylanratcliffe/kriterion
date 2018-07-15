class Kriterion
  class Backend
    @@nackend = nil

    def self.set(backend)
      @@backend = backend
    end

    def self.get
      @@backend
    end
  end
end
