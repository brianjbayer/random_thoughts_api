# frozen_string_literal: true

RSpec.shared_examples 'unauthorized response' do
  it 'returns "status": 401' do
    expect(json_body['status']).to be(401)
  end

  it 'returns "error": "unauthorized"' do
    expect(json_body['error']).to eql('unauthorized')
  end

  it 'returns "message" indicating invalid login' do
    expect(json_body['message']).to include('Invalid login')
  end
end
