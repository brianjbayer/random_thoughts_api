# frozen_string_literal: true

RSpec.shared_examples 'bad_request response' do
  it 'returns "status": 400' do
    expect(json_body['status']).to be(400)
  end

  it 'returns "error": "bad_request"' do
    expect(json_body['error']).to eql('bad_request')
  end

  it 'returns "message" indicating parameters are missing' do
    expect(json_body['message']).to include('param is missing or the value is empty')
  end
end
