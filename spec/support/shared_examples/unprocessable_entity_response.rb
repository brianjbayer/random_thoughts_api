# frozen_string_literal: true

RSpec.shared_examples 'unprocessable_entity response' do
  it 'returns "status": 422' do
    expect(json_body['status']).to be(422)
  end

  it 'returns "error": "not_found"' do
    expect(json_body['error']).to eql('unprocessable_entity')
  end

  it 'returns "message": indicating validation failed' do
    expect(json_body['message']).to include('Validation failed: ')
  end
end
