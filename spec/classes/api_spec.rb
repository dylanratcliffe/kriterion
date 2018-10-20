require 'spec_helper'
require 'kriterion/api'
require 'shared_examples/endpoint_spec'

RSpec.describe Kriterion::API do
  context 'with no opts' do
    let(:api) { Kriterion::API.new.helpers }

    it 'should not fail to initialise' do
      # We need the object to initialise so we can pass mocker backends to it
      # for testing
      expect { Kriterion::API.new }.not_to raise_error
    end

    it 'should accept a backend passed to it' do
      # Calling `new` on Kriterion::API doesn't actually return us a
      # Keriterion::API object, it returns a Sinatra::Wrapper object. To get the
      # the object we want to have to drill into it a bit
      backend = Kriterion::Backend.new

      expect { api.backend = backend }.not_to raise_error
    end
  end

  describe 'endpoints' do
    before(:all) do
      @middleware  = Kriterion::API.new
      @api         = @middleware.helpers
      @backend     = Kriterion::Backend.new
      @api.backend = @backend
    end

    before(:each) do
      Kriterion::API.stubs(:new).returns(@middleware)
    end

    let(:backend) { @backend }

    describe 'the /standards endpoint' do
      it_should_behave_like 'a friendly endpoint:', 'standards'

      it 'should properly search when passed a name' do
        backend.expects(:find_standards).with(
          { name: 'lame_standard' },
          recurse: false
        ).returns(nil)

        get '/standards/lame_standard'

        expect(last_response).to be_ok
      end
    end

    describe 'the /sections endpoint' do
      require 'kriterion/section'

      it_should_behave_like 'a friendly endpoint:', 'sections'

      it 'should handle a standard param' do
        backend.expects(:find_sections).with(
          { standard: 'cool_standard' },
          recurse: false
        ).returns(nil)

        get '/sections?standard=cool_standard'

        expect(last_response).to be_ok
      end

      it 'should be able to return subsections' do
        parent_section = Kriterion::Section.new({
          'uuid' => 'a8ac86b2-3f6b-4663-8516-181fbc7faff7',
          'name' => '1.1',
        })

        child_section = Kriterion::Section.new({
          'uuid'        => 'b4536b56-e44b-4e75-9d2a-e22459ebff17',
          'name'        => '1.1.1',
          'parent_uuid' => 'a8ac86b2-3f6b-4663-8516-181fbc7faff7',
        })

        parent_section.sections << child_section

        backend.expects(:find_sections).with(
          { uuid: 'a8ac86b2-3f6b-4663-8516-181fbc7faff7' },
          recurse: true
        ).returns([parent_section])

        get '/sections/a8ac86b2-3f6b-4663-8516-181fbc7faff7/sections'

        expect(last_response).to be_ok
        body = JSON.parse(last_response.body)
        expect(body).to be_a(Array)
        expect(body.length).to be(1)
        expect(body[0]).to include(
          'uuid'        => 'b4536b56-e44b-4e75-9d2a-e22459ebff17',
          'name'        => '1.1.1',
          'parent_uuid' => 'a8ac86b2-3f6b-4663-8516-181fbc7faff7'
        )
      end
    end

    describe 'the /resources endpoint' do
      it_should_behave_like 'a friendly endpoint:', 'resources'

      it 'should handle a item param' do
        backend.expects(:find_resources).with(
          { parent_uuid: 'b4536b56-e44b-4e75-9d2a-e22459ebff17' },
          recurse: false
        ).returns(nil)

        get '/resources?item=b4536b56-e44b-4e75-9d2a-e22459ebff17'

        expect(last_response).to be_ok
      end

      it 'should handle a passed uuid' do
        backend.expects(:find_resources).with(
          { uuid: 'b4536b56-e44b-4e75-9d2a-e22459ebff17' },
          recurse: false
        ).returns(nil)

        get '/resources/b4536b56-e44b-4e75-9d2a-e22459ebff17'

        expect(last_response).to be_ok
      end
    end
  end
end
