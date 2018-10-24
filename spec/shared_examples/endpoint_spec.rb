RSpec.shared_examples 'a friendly endpoint:' do |endpoint|
  it 'should default to basic mode' do
    # Every time I execute this it's creating a new API object which means
    # that my mocks don't persist and we end up with a bunch of ugly output.
    # Need to work out a way to ensure that the mocks work
    backend.expects(:"find_#{endpoint}").with(
      instance_of(Hash),
      recurse: false,
    ).returns(nil)

    get "/#{endpoint}"

    expect(last_response).to be_ok
  end

  it 'should handle full mode' do
    backend.expects(:"find_#{endpoint}").with(
      instance_of(Hash),
      recurse: true,
    ).returns(nil)

    get "/#{endpoint}?level=full"

    expect(last_response).to be_ok
  end

  it 'should handle invalid data' do
    backend.expects(:"find_#{endpoint}").with(
      instance_of(Hash),
      recurse: false,
    ).returns(nil)

    get "/#{endpoint}/lame_standard?isitooearlyfor=beer"

    expect(last_response).to be_ok
  end
end
