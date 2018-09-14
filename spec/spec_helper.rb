require 'bundler/setup'
require 'kriterion'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../lib/kriterion/api.rb', __dir__

module RSpecMixin
  include Rack::Test::Methods

  def app
    described_class
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Include the mixin defined above
  config.include RSpecMixin

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.formatter = :documentation
  config.mock_with :mocha
end
