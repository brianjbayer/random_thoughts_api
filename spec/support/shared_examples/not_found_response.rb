# frozen_string_literal: true

RSpec.shared_examples 'not_found response' do
  it 'returns "status": 404' do
    expect(json_body['status']).to be(404)
  end

  it 'returns "error": "not_found"' do
    expect(json_body['error']).to eql('not_found')
  end

  it 'returns "message": indicating it could not find' do
    expect(json_body['message']).to include("Couldn't find ")
  end
end
