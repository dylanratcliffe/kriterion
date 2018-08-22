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
    # required due to the way that Sinatra initialises things This adds the
    # initialize method etc.
    @@instance = nil

    def initialize(opts = {})
      # If there is already an instance, copy the objects from that
      if @@instance
        @queue_uri = @@instance.queue_uri
        @metrics   = @@instance.metrics
        @backend   = @@instance.backend
      else
        @queue_uri, @metrics, @backend = Kriterion::Connector.connections(opts)
        @@instance = self
      end
      super()
      logger.info "Initialised Kritioner API version #{Kriterion::VERSION}"
    end

    set :bind, '0.0.0.0'
    set :environment, :test

    # Set headers and default values
    before do
      headers 'Content-Type' => 'application/json'
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

    private

    # Finds things in the backend and returns them as JSON
    def find(thing, query = {})
      result = backend.send("find_#{thing}", query, recurse: options[:recurse])

      if result.is_a? Array
        result.map do |object|
          object.to_h(options[:mode])
        end.to_json
      else
        result.to_h(options[:mode]).to_json
      end
    end

    # Returns options that are relevant to the queries we will be doing based
    # on the params that were passed
    def options
      # Defualt level should be full
      level = params['level'] || 'full'

      # Convert all other params to symbols for later use
      sym_params = params.each_with_object({}) do |memo, (k, v)|
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
