require 'spec_helper'
require 'kriterion/worker'

RSpec.describe Kriterion::Worker do
  let(:worker) do
    Kriterion::Worker.new(
      uri: 'http://127.0.0.1:5555/invalid',
      queue: 'foo',
      backend: 'stub'
    )
  end

  let(:backend) { Kriterion::Backend.new }

  before(:each) do
    Kriterion::Backend.stubs(:get).returns(backend)
  end

  context 'when queue is unavailable' do
    it 'should keep trying' do
      runner = sequence('runner')

      worker.expects(:keep_running?).returns(true).in_sequence(runner)
      worker.expects(:keep_running?).returns(true).in_sequence(runner)
      worker.expects(:keep_running?).returns(false).in_sequence(runner)

      expect { worker.run(0) }.not_to raise_error
    end
  end

  context 'with a working queue' do
    context 'with no reports' do
      it 'should wait for reports' do
        waiting  = sequence('waiting')
        response = Object.new

        Net::HTTP.expects(:get_response).returns(response).at_least_once

        # Set up the sequence of mocking
        worker.expects(:keep_running?).returns(true).in_sequence(waiting)
        response.expects(:code).returns('204').in_sequence(waiting)
        worker.expects(:keep_running?).returns(true).in_sequence(waiting)
        response.expects(:code).returns('200').in_sequence(waiting)
        response.expects(:body).returns(responses[0]).in_sequence(waiting)
        worker.expects(:process_report).with(reports[0]).returns(nil).in_sequence(waiting)
        worker.expects(:keep_running?).returns(false).in_sequence(waiting)

        worker.run(0)
      end
    end
  end
end
