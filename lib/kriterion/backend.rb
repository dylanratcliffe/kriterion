require 'kriterion/metrics'

class Kriterion
  class Backend
    @@backend = nil

    attr_reader :metrics

    def initialize(opts = {})
      @metrics = opts[:metrics] || Kriterion::Metrics.new
    end

    # This is the meat of what a backend is. This section defines the following
    # methods:
    #
    #   - find_standard
    #   - find_standards
    #   - find_section
    #   - find_sections
    #   - find_item
    #   - find_items
    #   - find_resource
    #   - find_resources
    #
    # These are the main methods that Kriterion will use to interact with the
    # backend. The backend must in turn implement the following methods:
    #
    #   - find(object_type, query, options)
    #   - insert(object)
    #
    %i[
      standard
      section
      item
      resource
      event
    ].each do |thing|
      define_method("find_#{thing}") do |query, opts|
        validate_opts opts

        # Call out to find_{thing}s
        results = send("find_#{thing}s", query, opts)

        # Validate that we only have one result and return it
        return results.first if results.count == 1
        raise "Found > 1 #{thing} with name: #{name}" if results.count > 1
        nil
      end

      define_method("find_#{thing}s") do |query, opts|
        result = nil
        metrics[:"backend_find_#{thing}s"] += Benchmark.realtime do
          result = find(thing, query, opts)
        end
        result
      end

      define_method("ensure_#{thing}") do |object|
        pk    = object.primary_key
        query = {
          pk => object.send(pk)
        }

        metrics[:backend_insert] += Benchmark.realtime do
          insert(object) unless send("find_#{thing}", query, recurse: false)
        end
        object
      end
    end

    def self.set(backend)
      @@backend = backend
    end

    def self.get
      @@backend
    end

    private

    def class_for(name)
      classes = {
        'standard' => Kriterion::Standard,
        'section'  => Kriterion::Section,
        'item'     => Kriterion::Item,
        'resource' => Kriterion::Resource,
        'event'    => Kriterion::Event
      }
      # If someone has passed in an object, just return the class
      return name.class if classes.value? name.class

      classes[name.to_s]
    end

    # Validate options hash
    def validate_opts(opts)
      valid_keys = [
        :recurse
      ]

      unless opts.keys.all? { |k| valid_keys.include?(k) }
        raise "Options hash is invalid #{opts}"
      end
    end
  end
end
