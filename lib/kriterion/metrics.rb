class Kriterion
  class Metrics
    def initialize
      @metrics = {}
    end

    def [](symbol)
      @metrics[symbol] || 0
    end

    def []=(symbol, value)
      @metrics[symbol] = value
    end

    def print
      logger.info 'Metrics:'
      @metrics.each do |name, value|
        logger.info "  #{name} #{value.round(2)}s"
      end
    end

    def reset!
      @metrics = {}
    end
  end
end
