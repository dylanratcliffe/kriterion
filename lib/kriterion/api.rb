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
      backend.find_standards(
        {},
        recurse: options[:recurse]
      ).map do |standard|
        standard.to_h(options[:mode])
      end.to_json
    end

    get '/standards/:name' do |name|
      backend.find_standard(
        { name: name },
        recurse: options[:recurse]
      ).to_h(options[:mode]).to_json
    end

    get '/sections' do
      backend.find_sections(
        { standard: options[:standard] },
        recurse: options[:recurse]
      ).map do |section|
        section.to_h(options[:mode])
      end.to_json
    end

    get '/sections/:uuid' do |uuid|
      backend.find_section(
        { uuid: uuid },
        recurse: options[:recurse]
      ).to_h(options[:mode]).to_json
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
      backend.find_resources(
        { parent_uuid: options[:item] },
        recurse: options[:recurse]
      ).map do |resource|
        resource.to_h(options[:mode])
      end.to_json
    end

    get '/resources/:uuid' do |uuid|
      backend.find_resource(
        { uuid: uuid },
        recurse: options[:recurse]
      ).to_h(options[:mode]).to_json
    end

    private

    # Returns options that are relevant to the queries we will be doing based
    # on the params that were passed
    def options
      # Defualt level should be full
      level = params['level'] || 'full'

      # Convert all other params to symbols for later use
      sym_params = params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

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
