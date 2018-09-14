require 'spec_helper'
require 'kriterion/api'

RSpec.describe Kriterion::API do
  context 'with no opts' do
    it 'should not fail to initialise' do
      # We need the object to initialise so we can pass mocker backends to it
      # for testing
      expect { Kriterion::API.new }.not_to raise_error
    end

    it 'should accept a backend passed to it' do
      # Calling `new` on Kriterion::API doesn't actually return us a
      # Keriterion::API object, it returns a Sinatra::Wrapper object. To get the
      # the object we want to have to drill into it a bit
      api     = Kriterion::API.new.helpers
      backend = Kriterion::Backend.new

      expect { api.backend = backend }.not_to raise_error
    end
  end

  context 'with a valid backend' do
    before do
      # Create the API and backend
      @backend = Kriterion::Backend.new

      # Simulate the non-critical methods.
      insert_return = nil
      @backend.stubs(:insert).with do |object|
        insert_return = object
        true
      end.returns(insert_return)
      @backend.stubs(:add_unchanged_node).returns(nil)
      @backend.stubs(:update_compliance!).returns(nil)
      @backend.stubs(:purge_events!).returns(nil)

      # Simulate all required calls to the `#find` method. There will be many
      # tests that require this so we will centralise the mocking as much as we
      # can to reduce duplication
      # TODO: This

      @middleware  = Kriterion::API.new
      @api         = @middleware.helpers
      @api.backend = @backend

      Kriterion::API.stubs(:new).returns(@api)
      Kriterion::Backend.stubs(:new).returns(@backend)
    end

    context 'in basic mode' do
      before(:each) do
        @api.expects(:params).returns('mode' => 'basic')
        @backend.expects(:find).returns
      end

      describe 'the /standards endpoint' do
        it 'should work with no params' do
          # require 'pry'
          # binding.pry
          get '/standards'
          # Rspec 2.x
          expect(last_response).to be_ok
        end
      end
    end
  end
end
