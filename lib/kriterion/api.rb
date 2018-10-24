require 'json'
require 'sinatra/base'
require 'kriterion/logs'
require 'kriterion/connector'

class Kriterion
  class API < Sinatra::Application
    attr_accessor :queue_uri
    attr_accessor :metrics
    attr_accessor :backend

    include Kriterion::Logs

    # We only every want to have one instance of this running at a time. This is
    # required due to the way that Sinatra initialises things, this adds the
    # initialize method etc.
    @@instance = nil

    def initialize(opts = nil)
      # If there is already an instance, copy the objects from that
      if @@instance
        @queue_uri = @@instance.queue_uri
        @metrics   = @@instance.metrics
        @backend   = @@instance.backend
      elsif opts
        @queue_uri, @metrics, @backend = Kriterion::Connector.connections(opts)
        @@instance = self
      end
      super
      logger.info "Initialised Kriterion API version #{Kriterion::VERSION}"
    end

    set :bind, '0.0.0.0'
    set :environment, :test

    # Set headers and default values
    before do
      headers(
        'Content-Type'                => 'application/json',
        'Access-Control-Allow-Origin' => '*'
      )
    end

    get '/standards' do
      find 'standards'
    end

    get '/standards/:name' do |name|
      find 'standards', name: name
    end

    get '/sections' do
      find 'sections', standard: options[:standard]
    end

    get '/sections/:uuid' do |uuid|
      find 'sections', uuid: uuid
    end

    get '/sections/:uuid/sections' do |uuid|
      # Get the main section
      parent = backend.find_section(
        { uuid: uuid },
        recurse: true
      )

      # Return all direct children
      parent.sections.map do |section|
        section.to_h(options[:mode])
      end.to_json
    end

    get '/resources' do
      find 'resources', parent_uuid: options[:item]
    end

    get '/resources/:uuid' do |uuid|
      find 'resources', uuid: uuid
    end

    get '/items' do
      case [options[:standard].nil?, options[:section].nil?]
      when [true, false]
        # Section supplied
        if options[:recurse]
          sections = backend.find_sections({ uuid: options[:section] }, recurse: true )
          items    = []

          # Loop over all the sections so that we get all child items
          until sections.empty?
            section = sections.pop
            items << section.items
            section.sections.each { |s| sections.push(s) }
          end
          items.flatten.map do |item|
            item.to_h(options[:mode])
          end.to_json
        else
          find 'items', parent_uuid: options[:section]
        end
      when [false, true]
        # Standard supplied
        find 'items', standard: options[:standard]
      else
        status 400
        body 'Must specify either standard or section'
      end
    end

    get '/items/:uuid' do |uuid|
      find 'items', uuid: uuid
    end

    get '/events' do
      resource = backend.find_resource(
        { uuid: options[:resource] },
        recurse: options[:recurse]
      )

      return [].to_json if resource.nil?

      find 'events', resource: resource.resource
    end

    private

    # Finds things in the backend and returns them as JSON
    def find(thing, query = {})
      result = backend.send("find_#{thing}", query, recurse: options[:recurse])

      case result
      when Array
        result.map do |object|
          object.to_h(options[:mode])
        end.to_json
      when Kriterion::Object
        result.to_h(options[:mode]).to_json
      else
        {}.to_json
      end
    end

    # Returns options that are relevant to the queries we will be doing based
    # on the params that were passed
    def options
      # Defualt level should be basic
      level = params['level'] || 'basic'

      # Convert all other params to symbols for later use
      sym_params = params.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
        memo
      end

      # Return all data
      sym_params.merge(mode_options[level])
    end

    def mode_options
      {
        'basic' => {
          recurse: false,
          mode: :basic
        },
        'full' => {
          recurse: true,
          mode: :full
        }
      }
    end
  end
end
